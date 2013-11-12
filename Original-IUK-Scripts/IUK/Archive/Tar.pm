=head1 NAME

Tails::IUK::Archive::Tar - wrap, and add to Archive::Tar::Wrapper for Incremental Upgrade Kit files

=cut

package Tails::IUK::Archive::Tar;

use Moose;
use Moose::Util::TypeConstraints qw{class_type};
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class qw{Dir File};
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

use 5.10.0;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Tails::IUK::Archive::Tar::Wrapper;
use Carp;
use File::Temp qw{tempdir};
use File::Which;
use Path::Class qw{dir file};
use Tails::IUK::Utils qw{run_as_root};


=head1 TYPES

=cut

class_type('Tails::IUK::Archive::Tar::Wrapper');


=head1 ATTRIBUTES

=cut

has 'filename' => (
    is       => 'ro',
    isa      => File,
    required => 1,
    coerce   => 1,
);

has 'sudo'        => lazy_build ro Bool;
has 'tar_exe'     => coerce lazy_build ro File;
has 'tempdir'     => coerce lazy_build ro Dir, predicate 'has_tempdir';

has 'tar_wrapper' => lazy_build ro 'Tails::IUK::Archive::Tar::Wrapper',
    handles => [ qw{list_all locate} ];


=head1 METHODS

=cut

method BUILD {
    $self->read_from($self->filename);
}

method _build_sudo    { 0 }
method _build_tar_exe { $self->sudo ? which('sudo-tar') : which('tar') }
method _build_tempdir { dir(tempdir(CLEANUP => 1), 'tar') }

method _build_tar_wrapper {
    my $tar_wrapper = Tails::IUK::Archive::Tar::Wrapper->new(
        tar                  => $self->tar_exe->stringify,
        tar_gnu_read_options => [ qw{--no-same-permissions --no-same-owner} ],
        tmpdir               => $self->tempdir,
        tmpdir_is_complete   => 1,
    );
    return $tar_wrapper;
}

method read_from ($file) {
    my $filename = $file->stringify;
    $self->tar_wrapper->read($filename) or confess("Error reading $filename");
    run_as_root(qw{chmod -R go+rX}, $self->tempdir);
}

method files {
    sort map { $_->[0] } @{$self->list_all()};
}

method get_content ($filename) {
    scalar(file($self->locate($filename))->slurp);
}

method clean {
    run_as_root(qw{rm --recursive --force --preserve-root}, $self->tempdir)
        if $self->has_tempdir;
}

method DEMOLISH {
    $self->clean;
}

no Moose;
1;
