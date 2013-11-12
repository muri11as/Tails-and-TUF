=head1 NAME

Tails::IUK::TargetFile::Download - download and verify a target file

=cut

package Tails::IUK::TargetFile::Download;

use Moose;
use Moose::Util::TypeConstraints qw{enum};
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class;
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

with 'MooseX::Getopt::Dashes';

use 5.10.0;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Carp;
use Carp::Assert;
use Cwd;
use Data::Dumper;
use Digest::SHA;
use File::Temp qw{tempfile};
use HTTP::Request;
use LWP::UserAgent;
use Path::Class;
use Tails::IUK::Utils;


=head1 TYPES

=cut

# FIXME(Wheezy): Squeeze's Moose::Util::TypeConstraints absolutely wants at least two members in an enum
enum 'Tails::IUK::TargetFile::HashType', ['sha256', 'xyz_invalid_xyz'];


=head1 ATTRIBUTES

=cut

has 'uri'         => required ro Str;
has 'hash_type'   => required ro 'Tails::IUK::TargetFile::HashType';
has 'hash_value'  => required ro Str;
has 'output_file' => coerce required ro 'Path::Class::File';
has 'size'        => required ro Int;


=head1 CONSTRUCTORS AND BUILDERS

=cut


=head1 METHODS

=cut

method fatal (@msg) {
    Tails::IUK::Utils::fatal(msg => \@msg);
}

method run () {
    my $ua  = LWP::UserAgent->new(ssl_opts => {
        verify_hostname => 0,
        SSL_verify_mode => 0,
    });
    unless ($ENV{HARNESS_ACTIVE} or $ENV{DISABLE_PROXY}) {
        #$ua->proxy([qw(http https)] => 'socks://127.0.0.1:9062');
	#Make this request go through our Proxy, not Tor
	$ua->proxy([qw(http https)] => 'http://128.238.102.109:8080');
    }
    $ua->protocols_allowed([qw(http https)]);
    my $req = HTTP::Request->new('GET', $self->uri);

    my ($temp_fh, $temp_filename) = tempfile;
    close $temp_fh;

    sub clean_fatal {
        my $self   = shift;
        my $unlink = shift;
        unlink $unlink;
        $self->fatal(@_);
    }

    $ua->max_size($self->size);
    my $res = $ua->request($req, $temp_filename);

    defined $res or clean_fatal($self, $temp_filename, sprintf(
        "Could not download '%s' to '%s': undefined result",
        $self->uri, $temp_filename,
    ));

    my $died_header = $res->header('X-Died');
    ! defined $died_header or clean_fatal($self, $temp_filename, sprintf(
        "Could not download '%s' to '%s', callback died:\n%s",
        $self->uri, $temp_filename, $died_header,
    ));

    $res->is_success or clean_fatal($self, $temp_filename, sprintf(
        "Could not download '%s' to '%s', request failed:\n%s\n",
        $self->uri, $temp_filename, $res->status_line,
    ));

    -s $temp_filename == $self->size or clean_fatal(
        $self, $temp_filename, sprintf(
            "The file '%s' was downloaded but its size (%d) should be %d",
            $self->uri, -s $temp_filename, $self->size,
    ));

    my $sha = Digest::SHA->new(256);
    $sha->addfile($temp_filename);
    $sha->hexdigest eq $self->hash_value or clean_fatal(
        $self, $temp_filename, sprintf(
            "The file '%s' was downloaded but its hash is not correct",
        $self->uri,
    ));

    rename($temp_filename, $self->output_file);
    # autodie is supposed to throw an exception on rename error,
    # but one can't be too careful.
    assert(-e $self->output_file);

    chmod 0644, $self->output_file;

    return 1;
}

no Moose;
1;
