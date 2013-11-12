=head1 NAME

Tails::IUK::Role::HasCodeset - role to get the codeset being used

=head1 SYNOPSIS

    See Tails::IUK::Frontend for a real-life usage example.

=cut

package Tails::IUK::Role::HasCodeset;
use Moose::Role;

our $VERSION = '0.3.8'; # VERSION

use namespace::autoclean;
use Try::Tiny;

has 'codeset'  => (
    isa        => 'Str',
    is         => 'ro',
    lazy_build => 1,
);

sub _build_codeset {
    my $codeset;
    try {
        require I18N::Langinfo;
        I18N::Langinfo->import(qw(langinfo CODESET));
        $codeset = langinfo(CODESET());
    } catch {
        die "No default character code set configured.\nPlease fix your locale settings.";
    };
    $codeset;
}

no Moose::Role;
1; # End of Tails::IUK::Role::HasCodeset
