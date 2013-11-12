=head1 NAME

Tails::IUK::UpdateDescriptionFile - describe and manipulate a Tails update-description file

=cut

package Tails::IUK::UpdateDescriptionFile;

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
use Data::Dumper;
use Dpkg::Version qw{version_compare};
use English qw{-no_match_vars};
use List::MoreUtils qw{any};
use List::Util qw{max sum};
use Path::Class;
use YAML::Any;


=head1 ATTRIBUTES

=cut

has "$_"    => required ro Str
    for (qw{product_name product_version build_target channel});

has updates =>
    lazy_build ro ArrayRef,
    traits => [ 'Array' ],
    handles => {
        count_updates   => 'count',
        all_updates     => 'elements',
    };

has update_paths =>
    lazy_build ro ArrayRef,
    traits => [ 'Array' ],
    handles => {
        count_update_paths => 'count',
        all_update_paths   => 'elements',
    };


=head1 CONSTRUCTORS AND BUILDERS

=cut

method _build_updates { return [] }

method _build_update_paths {
    my @update_paths;
    foreach my $update ($self->all_updates) {
        exists $update->{'update-paths'} or $update->{'update-paths'} = [];
        foreach my $path (@{$update->{'update-paths'}}) {
            foreach my $key (qw{type target-files}) {
                assert(exists  $path->{$key});
                assert(defined $path->{$key});
            }
            $path->{'details-url'} = $update->{'details-url'};
            $path->{'update-type'} = $update->{'type'};
            $path->{'version'}     = $update->{'version'};
            $path->{'total-size'}  = sum(map { $_->{size} } @{$path->{'target-files'}});
            push @update_paths, $path;
        }
    }
    return \@update_paths;
}

sub new_from_text {
    my $class = shift;
    my $text  = shift;

    my $data = YAML::Any::Load($text);

    my %args;
    foreach my $key    (qw{product-name product-version channel build-target updates}) {
        next unless exists $data->{$key};
        my $attribute = $key; $attribute =~ s{-}{_}xmsg;
        $args{$attribute} = $data->{$key};
    }

    $class->new(%args);
}


=head1 METHODS

=cut

method contains_update_path () {
    $self->count_update_paths > 0;
}

method incremental_update_paths () {
    grep { $_->{type} eq 'incremental' } $self->all_update_paths;
}

method full_update_paths () {
    grep { $_->{type} eq 'full' } $self->all_update_paths;
}

method contains_incremental_update_path () {
    $self->incremental_update_paths > 0;
}

method contains_full_update_path () {
    $self->full_update_paths > 0;
}

method incremental_update_path () {
    path_to_newest_version($self->incremental_update_paths);
}

method full_update_path () {
    path_to_newest_version($self->full_update_paths);
}


=head1 FUNCTIONS

=cut

sub path_to_newest_version {
    my @paths = @_;
    assert(@paths);

    my $current_best_path = { version => '-1' };

    foreach my $path (@paths) {
        $current_best_path = $path
            if version_compare($path->{version}, $current_best_path->{version}) == 1;
    }

    return $current_best_path;
}

no Moose;
1;
