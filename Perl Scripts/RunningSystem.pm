=head1 NAME

Tails::IUK::RunningSystem - class that represents the running Tails system

=cut

package Tails::IUK::RunningSystem;

use Moose;
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class;
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

use 5.10.1;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Carp;
use Carp::Assert;
use Carp::Assert::More;
use Data::Dumper;
use Path::Class;
use Try::Tiny;


=head1 ATTRIBUTES

=cut

has 'update_description_url_schema_version' => lazy_build ro Int;

has "$_" => lazy_build ro Str
    for (
        qw{baseurl product_name product_version build_target channel},
        qw{update_description_file_url update_description_sig_url},
        qw{os_release_file},
    );


=head1 CONSTRUCTORS AND BUILDERS

=cut

method _build_update_description_url_schema_version { 1 }
method _build_os_release_file { '/etc/os-release' }
method _build_product_name    { $self->os_release_get('TAILS_PRODUCT_NAME') }
method _build_product_version { $self->os_release_get('TAILS_VERSION_ID')   }
method _build_baseurl         { 'http://www.toannv.com' }

method _build_build_target {
    my $arch = `dpkg --print-architecture`; chomp $arch; return $arch;
}

method _build_channel   {
    my $channel;
    try { $channel = $self->os_release_get('TAILS_CHANNEL') };
    defined $channel ? $channel : 'stable';
}

method _build_update_description_file_url {
    sprintf(
        "%s/update/v%d/%s/%s/%s/%s/updates.yml",
        $self->baseurl,
        $self->update_description_url_schema_version,
        $self->product_name,
        $self->product_version,
        $self->build_target,
        $self->channel,
    );
}

method _build_update_description_sig_url {
    $self->update_description_file_url . '.pgp';
}


=head1 METHODS

=cut

=head2 os_release_get

Retrieve a value from os-release file,
as specified by
http://www.freedesktop.org/software/systemd/man/os-release.html

Throws an exception if not found.

=cut
method os_release_get ($key) {
    assert(-e $self->os_release_file);
    assert_like($key, qr{[_A-Z]+});

    my $fh = file($self->os_release_file)->openr;

    while (<$fh>) {
        chomp;
        if (my ($value) = (m{\A $key [=] ["] (.*) ["] \z}xms)) {
            return $value;
        }
    }

    croak(sprintf(
        "Could not retrieve value of '%s' in '%s'",
        $key, $self->os_release_file,
    ));
}

no Moose;
1;
