=head1 NAME

Tails::IUK::Role::HasEncoding - role to provide an Encode::Encoding objet

=head1 SYNOPSIS

    See Tails::IUK::Frontend for a real-life usage example.

=cut

package Tails::IUK::Role::HasEncoding;
use Moose::Role;

our $VERSION = '0.3.8'; # VERSION

use namespace::autoclean;
with 'Tails::IUK::Role::HasCodeset';
use Encode qw{find_encoding};
use Moose::Util::TypeConstraints;

class_type('Encode::Encoding');
class_type('Encode::XS');

has 'encoding' => (
    isa        => 'Encode::Encoding | Encode::XS',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_encoding {
    my $self = shift;
    find_encoding($self->codeset);
}

no Moose::Role;
1; # End of Tails::IUK::Role::HasEncoding
