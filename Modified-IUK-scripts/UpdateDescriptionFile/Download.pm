=head1 NAME

Tails::IUK::UpdateDescriptionFile::Download - download and verify an update description file

=cut

package Tails::IUK::UpdateDescriptionFile::Download;

use Moose;
use Moose::Util::TypeConstraints qw{class_type};
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class;
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

with 'MooseX::Getopt::Dashes';

use 5.10.1;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Carp;
use Carp::Assert;
use Carp::Assert::More;
use Data::Dumper;
use English qw{-no_match_vars};
use File::Temp qw{tempfile};
use GnuPG::Interface;
use HTTP::Request;
use IO::Handle;

use IO::Socket::SSL;
use Net::SSLeay;
BEGIN {
    eval { require Env; };
    unless ($ENV{SSL_NO_VERIFY}) {
        my $cafile = $ENV{HTTPS_CA_FILE};
        $cafile  //= '/etc/ssl/certs/UTN_USERFirst_Hardware_Root_CA.pem';
        IO::Socket::SSL::set_ctx_defaults(
            verify_mode => Net::SSLeay->VERIFY_PEER(),
            ca_file => $cafile,
        );
    }
}
use LWP::UserAgent; # needs to be *after* IO::Socket::SSL's initialization

use Path::Class;
use Tails::IUK::RunningSystem;
use Tails::IUK::Utils;
use YAML::Any;


=head1 TYPES

=cut

class_type 'Tails::IUK::RunningSystem';


=head1 ATTRIBUTES

=cut

has 'max_download_size' => lazy_build ro Int;
has "$_" => lazy_build ro Str
    for (qw{override_baseurl override_build_target override_os_release_file
            trusted_gnupg_homedir});
has 'running_system' =>
    lazy_build ro 'Tails::IUK::RunningSystem',
    handles => [
        qw{update_description_file_url update_description_sig_url},
        qw{product_name product_version build_target channel}
    ];


=head1 CONSTRUCTORS AND BUILDERS

=cut

method _build_max_download_size { 8 * 2**10 }

method _build_trusted_gnupg_homedir     {
    my $trusted_gnupg_homedir = '/usr/share/tails-iuk/trusted_gnupg_homedir';
    assert(-d $trusted_gnupg_homedir);
    return $trusted_gnupg_homedir;
}

method _build_running_system {
    my @args;
    for (qw{baseurl build_target os_release_file}) {
        my $attribute = "override_$_";
        my $predicate = "has_$attribute";
        if ($self->$predicate) {
            push @args, ($_ => $self->$attribute)
        }
    }
    Tails::IUK::RunningSystem->new(@args);
}


=head1 METHODS

=cut

method fatal (@msg) {
    Tails::IUK::Utils::fatal(msg => \@msg);
}

=head2 get_url

Returns decoded content found at URL.
Throws an exception on detected failure.

=cut

method get_url ($url) {
    my $ua  = LWP::UserAgent->new();
    unless ($ENV{HARNESS_ACTIVE} or $ENV{DISABLE_PROXY}) {
        #$ua->proxy([qw(http https)] => 'socks://127.0.0.1:9062');
	#Make this request go through our Proxy, not Tor
	$ua->proxy([qw(http https)] => 'http://0.0.0.0:8080');
    }
    #allow both http and https
    $ua->protocols_allowed([qw(http https)]);
    $ua->max_size($self->max_download_size);
	#Gives us the ability to be able to see the progress of our downloads, for demos and such. -CM
    $ua->show_progress(1);
    my $res = $ua->request(HTTP::Request->new('GET', $url));

    defined $res or croak(sprintf(
        "Could not download '%s', undefined result", $url
    ));

    my $died_header = $res->header('X-Died');
    ! defined $died_header or croak(sprintf(
        "Could not download '%s', callback died: %s", $url, $died_header,
    ));

    $res->is_success or croak(sprintf(
        "Could not download '%s', request failed: %s\n",
        $url, $res->status_line,
    ));

    my $decoded_content = $res->decoded_content;

    assert(defined $decoded_content);
    length $decoded_content or croak(sprintf(
        "Downloaded empty file at '%s'\n", $url
    ));

    length $decoded_content <= $self->max_download_size or croak(sprintf(
        "Downloaded from '%s' but the downloaded content (%d) should be smaller than %d",
        $url, length($decoded_content), $self->max_download_size,
    ));

    return $decoded_content;
}

method verify_signature ($description, $signature) {
    my $gnupg = GnuPG::Interface->new();
    $gnupg->options->hash_init(
        homedir    => $self->trusted_gnupg_homedir,
        # We decide what key should be trusted by a given Tails,
        # and we won't put a key created in the future in there,
        # so if a key appears to be created in the future,
        # it must be because the clock has problems,
        # so we can ignore that.
        # Same for a key that appears to be expired.
        # Disable locking entirely: our GnuPG homedir is read-only.
        extra_args => [
            qw{--ignore-valid-from --ignore-time-conflict --lock-never}
        ],
    );

    my   ($signature_fh,   $signature_file)   = tempfile(CLEANUP => 1);
    print $signature_fh    $signature;
    close $signature_fh;

    my   ($description_fh, $description_file) = tempfile(CLEANUP => 1);
    print $description_fh  $description;
    close $description_fh;

    my ($stdout, $stderr) = (IO::Handle->new(), IO::Handle->new());
    my $pid = $gnupg->verify(
        handles => GnuPG::Handles->new(stdout => $stdout, stderr => $stderr),
        command_args => [ $signature_file, $description_file ],
    );
    waitpid $pid, 0;

    return $CHILD_ERROR == 0;
}

method matches_running_system ($description_str) {
    assert(defined $description_str);
    my $description = YAML::Any::Load($description_str);
    assert_hashref($description);
    foreach (qw{product_name product_version build_target channel}) {
        my $accessor = my $field = $_;
        $field =~ s{_}{-}gxms;
        exists  $description->{$field}             or return;
        defined $description->{$field}             or return;
        $description->{$field} eq $self->$accessor or return;
    }
    return 1;
}

method run () {
    my $description = $self->get_url($self->update_description_file_url);
    #Disable signature verifying for updates.yml since we don't have Tails key to sign this file
    #my $signature   = $self->get_url($self->update_description_sig_url );

    #$self->verify_signature($description, $signature)
        #or croak("Invalid signature");
    $self->matches_running_system($description)
        or croak("Does not match running system");
    print $description;
    return;
}

no Moose;
1;
