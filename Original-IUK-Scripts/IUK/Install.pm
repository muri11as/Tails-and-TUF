=head1 NAME

Tails::IUK::Install - install an Incremental Upgrade Kit

=cut

package Tails::IUK::Install;

use Moose;
use Moose::Util::TypeConstraints qw{class_type};
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
use Carp::Assert::More;
use Cwd;
use Data::Dumper;
use File::Copy;
use Path::Class;
use File::Temp qw{tempdir tempfile};
use Try::Tiny;

use Tails::IUK::Read;
use Tails::IUK::Utils qw{run_as_root space_available};


=head1 TYPES

=cut

class_type('Tails::IUK::Read');


=head1 ATTRIBUTES

=cut

has 'reader' =>
    lazy_build ro 'Tails::IUK::Read',
    handles => [ qw{list_archives file delete_files delete_files_count locate space_needed squashfs_in_archive} ];

has 'liveos_mountpoint' => coerce lazy_build rw 'Path::Class::Dir';

has 'tempdir'       => lazy_build ro 'Path::Class::Dir', predicate 'has_tempdir';
has 'modules_file'  => lazy_build ro 'Path::Class::File';
has 'from_file'     => required ro 'Str';

has 'installed_squashfs' =>
    lazy_build ro 'ArrayRef[Str]',
    traits => [ 'Array' ],
    handles => {
        record_installed_squashfs => 'push',
        all_installed_squashfs    => 'elements',
    };


=head1 CONSTRUCTORS, BUILDERS AND DESTRUCTORS

=cut

method _build_tempdir {
    $self->remount_liveos_rw;

    my $base_live_tmp_dir = $self->liveos_mountpoint->subdir('tmp')->stringify;

    # --parents is used to avoid error if existing, not to create parents.
    run_as_root('mkdir', '--parents', $base_live_tmp_dir);
    -d $base_live_tmp_dir or $self->fatal("Could not make '$base_live_tmp_dir' directory: $!");

    my $tempdir = `sudo -n mktemp --directory --tmpdir=$base_live_tmp_dir`;
    chomp $tempdir;
    -d $tempdir or $self->fatal("Could not make '$tempdir' temporary directory: $!");

    # This is useless in Tails, but useful for testing.
    run_as_root(qw{chmod -R go+rX}, $base_live_tmp_dir);

    dir($tempdir);
}

sub _build_liveos_mountpoint {
    my $self = shift;
    dir('/lib/live/mount/medium');
}

method _build_installed_squashfs { [] }

method _build_modules_file {
    file($self->liveos_mountpoint, 'live', 'Tails.module');
}

method _build_reader {
    Tails::IUK::Read->new_from_file(
        $self->from_file,
        tempdir => $self->tempdir,
    );
}

method clean {
    run_as_root(qw{rm --recursive --force --preserve-root}, $self->tempdir)
        if $self->has_tempdir;
}

method DEMOLISH {
    $self->clean;
}


=head1 METHODS

=cut

method fatal (@msg) {
    Tails::IUK::Utils::fatal(
        msg               => \@msg,
        rmtree            => $self->has_tempdir ? [ $self->tempdir ] : [],
        rmtree_as_root    => 1,
    );
}

method extracted_archives {
    return grep {
        $_ =~ m{
                   [.] tar       # literal .tar
                   (?: [.] bz2 )? # possibly followed by literal .bz2
                   \z            # at the end of the string
           }xms;
    } $self->tempdir->children;
}

method space_available {
    space_available($self->liveos_mountpoint->stringify);
}

method update_modules_file {
    my @installed_squashfs = $self->all_installed_squashfs;

    my $append_str = join("\n", map { file($_)->basename } @installed_squashfs);
    if (length($append_str)) {
        my ($temp_fh, $temp_file) = tempfile;
        copy($self->modules_file->stringify, $temp_fh)
            or $self->fatal(sprintf(
                "Could not copy modules file ('%s') to temporary file ('%s')",
                $self->modules_file, $temp_file,
            ));
        close $temp_fh;

        $temp_fh = file($temp_file)->open('a');
        say $temp_fh $append_str;
        close $temp_fh;

        run_as_root('cp', '--force', $temp_file, $self->modules_file);
    }
}

method remount_liveos_rw {
    run_as_root(qw{mount -o}, "remount,rw", $self->liveos_mountpoint);
}

method run {
    unless ($self->space_available > $self->space_needed) {
        $self->fatal(
            "There is too little available space on Tails system partition, aborting"
        );
    }

    $self->remount_liveos_rw;

    my $orig_cwd = getcwd;
    foreach (sort $self->list_archives) {
        my $archive_filename = $_;

        chdir $self->liveos_mountpoint;
        # In a real Tails, /lib/live/mount/medium is not writable by non-root.
        run_as_root('tar', '-x', '--no-same-owner', '--no-same-permissions',
                    '-f', $self->locate($archive_filename));

        $self->record_installed_squashfs($self->squashfs_in_archive(
            $self->locate($archive_filename)
        ));
    }
    chdir $orig_cwd;

    if ($self->delete_files_count) {
        run_as_root(
            'rm', '--recursive', '--force',
            map { file($self->liveos_mountpoint, $_) } @{$self->delete_files}
        );
    }

    $self->update_modules_file;

    $self->clean;
}

no Moose;
1;
