=head1 NAME

Tails::IUK::Archive::Tar::Wrapper - custom subclass of Archive::Tar::Wrapper for Incremental Upgrade Kit files

=cut

package Tails::IUK::Archive::Tar::Wrapper;

use strict;
use warnings;

use parent 'Archive::Tar::Wrapper';

use File::Temp qw(tempdir);
use Log::Log4perl qw(:easy);
use File::Spec::Functions;
use File::Spec;
use File::Path;
use Tails::IUK::Utils qw{run_as_root};

###########################################
sub new {
###########################################
    my($class, %options) = @_;

    my $self = {
        tar                  => undef,
        tmpdir               => undef,
        tmpdir_is_complete   => undef,
        tar_read_options     => '',
        tar_write_options    => '',
        tar_gnu_read_options => [],
        dirs                 => 0,
        max_cmd_line_args    => 512,
        ramdisk              => undef,
        %options,
    };

    bless $self, $class;

    $self->{tar} = bin_find("tar") unless defined $self->{tar};
    $self->{tar} = bin_find("gtar") unless defined $self->{tar};

    if( ! defined $self->{tar} ) {
        LOGDIE "tar not found in PATH, please specify location";
    }

    if(defined $self->{ramdisk}) {
        my $rc = $self->ramdisk_mount( %{ $self->{ramdisk} } );
        if(!$rc) {
            LOGDIE "Mounting ramdisk failed";
        }
        $self->{tmpdir} = $self->{ramdisk}->{tmpdir};
    } else {
        if ($self->{tmpdir}) {
            if (! $self->{tmpdir_is_complete}) {
                $self->{tmpdir} = tempdir(DIR => $self->{tmpdir});
            }
        }
        else {
            $self->{tmpdir} = tempdir();
        }
    }

    $self->{tardir} = File::Spec->catfile($self->{tmpdir}, "tar");
    run_as_root('mkdir', '--parents', $self->{tardir});
    -d $self->{tardir} or LOGDIE "Cannot make $self->{tardir} ($!)";
    run_as_root(qw{chmod -R go+rX}, $self->{tardir});

    $self->{objdir} = tempdir();

    return $self;
}

1;
