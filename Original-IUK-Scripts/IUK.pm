=head1 NAME

Tails::IUK - Incremental Upgrade Kit class

=cut

package Tails::IUK;

use Moose;
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
use Device::Cdio::ISO9660;
use Device::Cdio::ISO9660::IFS;
use English qw{-no_match_vars};
use File::Basename;
use File::Copy;
use File::Spec::Functions;
use File::Temp qw{tempdir tempfile};
use Path::Class;
use Tails::IUK::Utils qw{extract_file_from_iso extract_here_file_from_iso run_as_root};
use Try::Tiny;
use YAML::Any;


=head1 ATTRIBUTES

=cut

has 'format_version' => lazy_build ro Str;
has 'squashfs_diff_name' => required ro Str;
has 'squashfs_diff'  => coerce lazy_build ro 'Path::Class::File';
has 'delete_files'   => lazy_build ro 'ArrayRef[Str]';
foreach (qw{old_iso new_iso}) {
    has $_ => required ro Str;
}
has 'outfile' => required coerce lazy_build ro 'Path::Class::File';
has 'new_kernels' => lazy_build ro 'ArrayRef[Str]';
has 'tarballs' => lazy_build ro 'ArrayRef[Str]';
has 'tempdir' => lazy_build ro 'Path::Class::Dir';
has 'tar_options' =>
    lazy_build ro 'ArrayRef[Str]',
    traits => ['Array'],
    handles => {
        list_tar_options => 'elements',
    };


=head1 FUNCTIONS

=cut

=head2 missing_files_in_isos

Returns the list of the basename of files present in $dir in $iso1,
and missing in $dir in $iso2, non-recursively.

Some was adapted from File::DirCompare:

    Copyright 2006-2007 by Gavin Carr
    This library is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

=cut
sub missing_files_in_isos {
    my $iso1 = shift;
    my $iso2 = shift;
    my $dir  = shift;

    my $read_iso_dir = sub {
        my $iso = shift;
        my $dir = shift;
        my $iso_obj = Device::Cdio::ISO9660::IFS->new(-source => $iso);
        map {
            Device::Cdio::ISO9660::name_translate($_->{filename});
        } $iso_obj->readdir($dir);
    };

    my @res;

    # List $dir1 and $dir2
    my (%d1, %d2);
    $d1{basename $_} = 1 foreach $read_iso_dir->($iso1, $dir);
    $d2{basename $_} = 1 foreach $read_iso_dir->($iso2, $dir);

    # Prune dot dirs
    delete $d1{''} if $d1{''};
    delete $d1{curdir()} if $d1{curdir()};
    delete $d1{updir()}  if $d1{updir()};
    delete $d2{''} if $d2{''};
    delete $d2{curdir()} if $d2{curdir()};
    delete $d2{updir()}  if $d2{updir()};

    my %u;
    for my $f (map { $u{$_}++ == 0 ? $_ : () } sort(keys(%d1), keys(%d2))) {
        push @res, $f unless $d2{$f};
    }

    return map { catfile($dir, $_) } @res;
}

=head2 updated_or_new_files_in_isos

Returns the list of the basename of files new or updated in $dir in $iso1,
wrt. $iso2, non-recursively.

Some was adapted from File::DirCompare:

    Copyright 2006-2007 by Gavin Carr
    This library is free software; you can redistribute it and/or modify it
    under the same terms as Perl itself.

=cut
sub updated_or_new_files_in_isos {
    my $iso1 = shift;
    my $iso2 = shift;
    my $dir  = shift;
    my $whitelist_patterns = shift;

    assert(-e $iso1);
    assert(-e $iso2);

    my $iso1_obj = Device::Cdio::ISO9660::IFS->new(-source => $iso1);
    my $iso2_obj = Device::Cdio::ISO9660::IFS->new(-source => $iso2);

    my $read_iso_dir = sub {
        my $iso_obj = shift;
        my $dir = shift;

        assert(defined($iso_obj));
        my @wanted_files;
        my @files_in_dir;
        try { @files_in_dir = $iso_obj->readdir($dir) };
        foreach (@files_in_dir) {
            my $filename = Device::Cdio::ISO9660::name_translate($_->{filename});
            foreach my $re (@{$whitelist_patterns}) {
                if ($filename =~ $re) {
                    push @wanted_files, $filename;
                    last;
                }
            }
        }
        return @wanted_files;
    };

    my @res;

    # List $dir in $iso1 and $iso2
    my (%d1, %d2);
    $d1{basename $_} = 1 foreach $read_iso_dir->($iso1_obj, $dir);
    $d2{basename $_} = 1 foreach $read_iso_dir->($iso2_obj, $dir);

    # Prune dot dirs
    delete $d1{''} if $d1{''};
    delete $d1{curdir()} if $d1{curdir()};
    delete $d1{updir()}  if $d1{updir()};
    delete $d2{''} if $d2{''};
    delete $d2{curdir()} if $d2{curdir()};
    delete $d2{updir()}  if $d2{updir()};

    my %u;
    for my $f (map { $u{$_}++ == 0 ? $_ : () } sort(keys(%d1), keys(%d2))) {
        # only in $iso1
        next unless $d2{$f};

        # only in $iso2
        unless ($d1{$f}) {
            push @res, $f;
            next;
        }

        # in both
        my $stat1 = $iso1_obj->stat(catfile($dir, $f));
        my $stat2 = $iso2_obj->stat(catfile($dir, $f));

        croak "File $f in $iso1 is a directory." if $stat1->{is_dir};
        croak "File $f in $iso2 is a directory." if $stat2->{is_dir};

        push @res, $f if
            extract_file_from_iso(catfile($dir, $f), $iso1)
                ne
            extract_file_from_iso(catfile($dir, $f), $iso2);
    }

    return map { file($dir, $_)->basename } @res;
}


=head1 METHODS

=cut

method _build_tempdir { dir(tempdir()); }
method _build_format_version { "1"; }
method _build_tar_options { [qw{--numeric-owner --owner=root --group=root}]; }
method _build_squashfs_diff  {
    my $tempdir = $self->tempdir;

    my $old_iso_mount      = dir($tempdir, 'old_iso');
    my $new_iso_mount      = dir($tempdir, 'new_iso');
    my $old_squashfs_mount = dir($tempdir, 'old_squashfs');
    my $new_squashfs_mount = dir($tempdir, 'new_squashfs');
    my $tmpfs              = dir($tempdir, 'tmpfs');
    my $union              = dir($tempdir, 'union');

    for my $dir ($old_iso_mount, $new_iso_mount, $old_squashfs_mount, $new_squashfs_mount, $tmpfs, $union) {
        mkdir $dir;
    }

    run_as_root("mount", "-o", "loop,ro", $self->old_iso, $old_iso_mount);
    my $old_squashfs = file($old_iso_mount, 'live', 'filesystem.squashfs');
    croak "SquashFS '$old_squashfs' not found in '$old_iso_mount'" unless -e $old_squashfs;
    run_as_root(qw{mount -t squashfs -o loop}, $old_squashfs, $old_squashfs_mount);

    run_as_root("mount", "-o", "loop,ro", $self->new_iso, $new_iso_mount);
    my $new_squashfs = file($new_iso_mount, 'live', 'filesystem.squashfs');
    croak "SquashFS '$new_squashfs' not found in '$new_iso_mount'" unless -e $new_squashfs;
    run_as_root(qw{mount -t squashfs -o loop}, $new_squashfs, $new_squashfs_mount);

    run_as_root(qw{mount -t tmpfs tmpfs}, $tmpfs);

    run_as_root(
        qw{mount -t aufs},
        "-o", sprintf("br=%s=rw:%s=ro", $tmpfs, $old_squashfs_mount),
        "none", $union
    );

    run_as_root(
        "rsync", "--archive", "--quiet", "--delete-after",
        sprintf("%s/", dir($new_squashfs_mount)),
        sprintf("%s/", dir($union)),
    );

    my ($squashfs_diff_fh, $squashfs_diff_filename) = tempfile();

    run_as_root(
        qw{sudo -n mksquashfs},
        $tmpfs,
        $squashfs_diff_filename,
        qw{-no-progress -noappend -comp xz}
    );

    foreach ($union, $tmpfs, $new_squashfs_mount, $new_iso_mount, $old_squashfs_mount, $old_iso_mount) {
        run_as_root("umount", $_);
    }

    return file($squashfs_diff_filename);
}

method _build_delete_files {
    my $old_iso_obj = Device::Cdio::ISO9660::IFS->new(-source=>$self->old_iso);
    my $new_iso_obj = Device::Cdio::ISO9660::IFS->new(-source=>$self->new_iso);
    my @delete_files;
    for (qw{isolinux live syslinux tails}) {
        push @delete_files,
            missing_files_in_isos($self->old_iso, $self->new_iso, $_);
    }
    return \@delete_files;
}

method _build_new_kernels {
    my @new_kernels =
        updated_or_new_files_in_isos(
            $self->old_iso,
            $self->new_iso,
            'live',
            [
                qr{^ vmlinuz [[:digit:]]* $}xms,
                qr{^ initrd  [[:digit:]]* [.] img $}xms,
            ],
        );
    return \@new_kernels;
}

method write_boot_tarball {
    my $orig_cwd = getcwd;
    my $boot_files_tempdir = tempdir(CLEANUP => 1);

    chdir $boot_files_tempdir;
    extract_here_file_from_iso('isolinux', $self->new_iso);

    chmod(0755, 'isolinux');
    chmod(0644, glob('isolinux/*'));

    rename 'isolinux', 'syslinux';
    rename 'syslinux/isolinux.cfg', 'syslinux/syslinux.cfg';

    foreach my $file (glob('syslinux/*')) {
        my $content = file($file)->slurp;
        $content =~ s{/isolinux/}{/syslinux/}gxms;
        my ($temp_fh, $temp_filename) = tempfile;
        print $temp_fh $content;
        close $temp_fh;
        rename $temp_filename, $file;
    }

    system(
        qw{tar -cj}, $self->list_tar_options,
        '-f', file($self->tempdir, 'boot.tar.bz2'), 'syslinux',
    );

    chdir $orig_cwd;

    return;
}

method write_system_tarball {
    my $tarball = file($self->tempdir, 'system.tar');

    chdir $self->squashfs_diff->dir;
    my $destname = file('live', $self->squashfs_diff_name);
    my $destdir  = file($destname)->dir;
    $destdir->mkpath;
    -d $destdir or croak(sprintf("Could not make directory '%s': $!"), $destdir);
    copy($self->squashfs_diff->basename, $destname)
        or croak(
            sprintf(
                "Could not copy '%s' to '%s': $!",
                $self->squashfs_diff->basename, $destname
            )
        );
    system(qw{tar --create}, $self->list_tar_options, '-f', $tarball, $destname);
    unlink $destname;

    my $new_kernels_tempdir = tempdir(CLEANUP => 1);
    chdir $new_kernels_tempdir;
    for my $new_kernel (@{$self->new_kernels}) {
        my $new_kernel_rel = file('live', $new_kernel);
        my $new_kernel_abs = file($new_kernels_tempdir, $new_kernel_rel);
        $new_kernel_abs->dir->mkpath;
        extract_here_file_from_iso($new_kernel_rel, $self->new_iso);
        system(
            qw{tar --append}, $self->list_tar_options, '-f', $tarball,
            $new_kernel_rel
        );
    }

    chdir $self->tempdir;  # allow temp dirs cleanup

    return;
}

method _build_tarballs {
    $self->write_boot_tarball;
    $self->write_system_tarball;
    return [ qw{boot.tar.bz2 system.tar} ];
}

method saveas ($outfile_name) {
    my $orig_cwd = getcwd;
    my $fh;
    chdir $self->tempdir;

    $fh = file('FORMAT')->openw;
    print $fh $self->format_version;
    close $fh;

    $fh = file('control.yml')->openw;
    print $fh YAML::Any::Dump({
        delete_files => $self->delete_files,
    });
    close $fh;

    chdir $self->tempdir;
    system(
        qw{tar --create}, $self->list_tar_options, '-f', $outfile_name,
        qw{FORMAT control.yml}
    );

    for (@{$self->tarballs}) {
        chdir file($_)->dir;
        system(
            qw{tar --append}, $self->list_tar_options, '-f', $outfile_name,
            file($_)->basename
        );
    }

    chdir $orig_cwd;  # allow temp dirs cleanup

    return;
}

method save () {
    $self->saveas($self->outfile);
}

method run () {
    $self->save;
}

no Moose;
1;
