=head1 NAME

Tails::IUK::Read - read Incremental Upgrade Kit files

=cut

package Tails::IUK::Read;

use Moose;
use Moose::Util::TypeConstraints qw{class_type};
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class;
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

use 5.10.0;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Carp;
use Carp::Assert;
use Cwd;
use Data::Dumper;
use File::Temp qw{tempdir tempfile};
use List::Util qw{sum};
use Path::Class;
use Try::Tiny;
use YAML::Any;

use Tails::IUK::Archive::Tar;
use Tails::IUK::Utils qw{run_as_root unpacked_size};

=head1 TYPES

=cut

class_type('Tails::IUK::Archive::Tar');


=head1 ATTRIBUTES

=cut

has 'file' => (
    isa => 'Path::Class::File',
    required => 1,
    is => 'ro',
);

has 'format_version' => lazy_build ro Str;
has 'control'        => lazy_build ro 'HashRef';
has 'delete_files'   => lazy_build ro 'ArrayRef[Str]',
    traits => [ 'Array' ],
    handles => {
        delete_files_count => "count",
    };

has 'archive' => (
    isa => 'Tails::IUK::Archive::Tar',
    is => 'ro',
    lazy_build => 1,
    handles => [ qw{get_content locate} ],
);

has 'files' => lazy_build ro 'ArrayRef[Str]';
has 'archives' => lazy_build ro 'ArrayRef[Path::Class::File]';
has 'tempdir'  => lazy_build ro 'Path::Class::Dir', predicate 'has_tempdir';


=head1 METHODS

=cut

method _build_format_version {
    my $format_version;
    try {
        $format_version = $self->get_content('FORMAT');
    } catch {
        croak "The format version cannot be determined:\n$_";
    };
    return $format_version;
}

method _build_archive {
    Tails::IUK::Archive::Tar->new(
        filename => $self->file->stringify,
        sudo     => 1,
        tempdir  => $self->tempdir,
    );
}

method _build_delete_files {
    my $delete_files = $self->control->{delete_files};
    $delete_files ||= [];
    return $delete_files;
}

method _build_control {
    my $control = YAML::Any::Load($self->get_content('control.yml'));
    $control = {} unless defined $control;
    return $control;
}

method _build_files { [ $self->archive->files ] }

method _build_archives {
    return [ map { file($_) } grep {
        $_ =~ m{
                   [.] tar       # literal .tar
                   (?: [.] bz2 )? # possibly followed by literal .bz2
                   \z            # at the end of the string
           }xms;
    } $self->list_files ];
}

method _build_tempdir { dir(tempdir(CLEANUP => 0)) };

method BUILD {
    my $format_version;
    try {
        $format_version = $self->format_version();
    } catch {
        croak "The format version cannot be determined:\n$_";
    };
    $format_version eq '1'
        or croak(sprintf("Unsupported format: %s", $format_version));
}

sub new_from_file {
    my $class = shift;
    my $filename = shift;

    return $class->new(
        file => file($filename),
        @_,
    );
}

method clean {
    run_as_root(qw{rm --recursive --force --preserve-root}, $self->tempdir)
        if $self->has_tempdir;
}

method DEMOLISH {
    $self->clean;
}

method list_files { @{$self->files} }

method space_needed {
    sum(0, map { unpacked_size($self->locate($_)) } $self->list_archives);
}

method contains_file ($filename) {
    1 == grep { $_ eq $filename } $self->list_files;
}

method squashfs_in_archive ($archive_filename) {
    my $tempdir = $self->tempdir->subdir(
        file($archive_filename)->basename . "_tempdir"
    );
    run_as_root('mkdir', '--parents', '--mode=0755', $tempdir);
    -d $tempdir or croak "Could not make '$tempdir' directory: $!";

    my $archive = Tails::IUK::Archive::Tar->new(
        filename => $archive_filename,
        tempdir  => $tempdir,
        sudo     => 1,
    );

    grep { m{[.] squashfs \z}xms } $archive->files;
}

method list_archives () { @{$self->archives} }

no Moose;
1;
