=head1 NAME

Tails::IUK::Utils - utilities for Tails IUK

=cut

package Tails::IUK::Utils;

use strict;
use warnings FATAL => 'all';
use 5.10.1;

our $VERSION = '0.3.8'; # VERSION

use Exporter;
our @ISA = qw{Exporter};
our @EXPORT = qw{extract_file_from_iso extract_here_file_from_iso fatal get_temp_dir make_archive_with_files_called make_iuk_with_files run_as_root space_available unpacked_size};

use autodie qw(:all);
use Archive::Tar;
use Carp;
use Carp::Assert;
use Carp::Assert::More;
use Cwd;
use Data::Dumper;
use English qw{-no_match_vars};
use File::Temp qw{tempdir};
use Filesys::Df;
use List::Util qw{sum};
use Method::Signatures::Simple;
use Path::Class;


=head1 FUNCTIONS

=cut

func extract_file_from_iso($file, $iso) {
    my @cmd = qw{bsdtar -x --no-same-permissions --to-stdout --fast-read};
    push @cmd, ('--file', $iso, $file);
    open(my $cmd, '-|', @cmd);
    my $output = do { local $/; <$cmd> };
    close $cmd;
    "${^CHILD_ERROR_NATIVE}" == 0 or croak "bsdtar failed: ${^CHILD_ERROR_NATIVE}";
    return $output;
}

func extract_here_file_from_iso($dir, $iso) {
    my @cmd = qw{bsdtar -x --no-same-permissions};
    push @cmd, ('--file', $iso, $dir);
    system(@cmd);
    "${^CHILD_ERROR_NATIVE}" == 0 or croak "bsdtar failed: ${^CHILD_ERROR_NATIVE}";
    return;
}

func run_as_root(@command) {
    system("sudo", "-n", @command);
}

sub get_temp_dir {
    dir(tempdir(CLEANUP => 1));
}

func fatal (%args) {
    assert(exists $args{msg});
    assert_isa($args{msg}, 'ARRAY');

    chdir '/';

    if (exists $args{rmtree} && defined $args{rmtree}) {
        if (exists $args{rmtree_as_root} && defined $args{rmtree_as_root} && $args{rmtree_as_root}) {
            run_as_root(
                qw{rm --recursive --force --preserve-root}, @{$args{rmtree}}
            );
        }
        else {
            foreach my $dir (@{$args{rmtree}}) {
                dir($dir)->rmtree;
            }
        }
    }

    croak(@{$args{msg}});
}

func unpacked_size ($archive_file) {
    assert(-e $archive_file);

    sum(0,
        map {
            my $ret = 0;
            if (my ($size) = (m{
                                   \A           # at the beginning of the string
                                   [-a-z]+      # permissions
                                   [[:space:]]+
                                   [[:digit:]]+ # owner
                                   /
                                   \d+          # group
                                   [[:space:]]+
                                   (\d+)        # size
                                   [[:space:]]+
                           }xms)) {
                $ret = $size;
            }
            $ret;
        } split(/\n/, `tar tv --numeric-owner -f $archive_file`)
    );
}

func make_archive_with_files_called ($archive_file, %args) {
    assert(exists $args{filenames});
    assert_isa($args{filenames}, 'ARRAY');
    assert_is(scalar(grep { exists $args{$_} } qw{size content}), 1);

    my $archive = Archive::Tar->new();
    my $orig_cwd = getcwd;
    chdir $archive_file->dir;
    foreach (@{$args{filenames}}) {
        file($_)->dir->mkpath;
        if (exists $args{content}) {
            my $fh = file($_)->openw;
            print $fh $args{content};
            close $fh;
        }
        elsif (exists $args{size}) {
            system("dd", "if=/dev/zero", "of=$_", "bs=1M", "count=".$args{size});
            ${^CHILD_ERROR_NATIVE} == 0 or croak("Failed to create ", $args{size}, "MB file '$_'.");
        }
        $archive->add_files($_);
    }
    $archive->write($archive_file)
        or croak("Failed to write '$archive_file':\n", $archive->error);
    chdir $orig_cwd;
}

func make_iuk_with_files ($iuk_filename, $tempdir, @files) {
    my $orig_cwd = getcwd;

    my $iuk = Archive::Tar->new();
    chdir $tempdir;

    my $fh = file('FORMAT')->openw; print $fh 1; close $fh;
    $iuk->add_files('FORMAT');
    unless (grep { $_ eq 'control.yml' } @files) {
        file('control.yml')->touch;
        $iuk->add_files('control.yml');
    }
    map { $iuk->add_files($_) or croak("Could not add file '$_'", $iuk->error) } @files;

    my $res = $iuk->write($iuk_filename);
    chdir $orig_cwd;
    $res or croak("Could not write IUK '$iuk_filename':\n", $iuk->error);
}

func space_available ($dir) {
    my $df = df($dir, 1); # "1" means "please return the value in bytes"

    return $df->{bavail};
}

1;
