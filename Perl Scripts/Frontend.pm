=head1 NAME

Tails::IUK::Frontend - lead Tails user through the process of updating the system, if needed

=cut

package Tails::IUK::Frontend;

use Moose;
use Moose::Util::TypeConstraints qw{class_type};
use MooseX::Method::Signatures;
use MooseX::Types::Moose qw( :all );
use MooseX::Types::Path::Class;
use MooseX::Has::Sugar::Saccharin;

our $VERSION = '0.3.8'; # VERSION

with 'Tails::IUK::Role::HasEncoding';
with 'MooseX::Getopt::Dashes';

use 5.10.1;
use namespace::autoclean;
use warnings FATAL => 'all';

use autodie qw(:all);
use Carp;
use Data::Dumper;
use English qw{-no_match_vars};
use Env;
use IPC::Run qw{run start finish};
use IPC::Run::SafeHandles;
use Number::Format qw(:subs);
use Path::Class;
use String::Errf qw{errf};
use Tails::IUK::RunningSystem;
use Tails::IUK::UpdateDescriptionFile;
use Tails::IUK::Utils;

use Locale::gettext;
use POSIX;
setlocale(LC_MESSAGES, "");
textdomain("tails-update-frontend");


=head1 TYPES

=cut

class_type 'Tails::IUK::RunningSystem';


=head1 ATTRIBUTES

=cut

has "$_" => lazy_build ro Str
    for (qw{override_baseurl override_build_target override_os_release_file
            override_trusted_gnupg_homedir});

has batch => lazy_build ro Bool;

has 'liveos_mountpoint' => coerce lazy_build ro 'Path::Class::Dir';

has 'running_system' =>
    lazy_build ro 'Tails::IUK::RunningSystem',
    handles => [
        qw{update_description_file_url update_description_sig_url},
        qw{product_name product_version build_target channel}
    ];


=head1 CONSTRUCTORS AND BUILDERS

=cut

method _build_batch { 0; }

method _build_running_system {
    my @args;
    for (qw{baseurl build_target os_release_file}) {
        my $attribute = "override_$_";
        my $predicate = "has_$attribute";
        if ($self->$predicate) {
            push @args, ($_ => $self->$attribute)
        }
    }
    Tails::IUK::RunningSystem->new(@args);
}


=head1 METHODS

=cut

method fatal (@msg) {
    my $text = join("\n", @msg);
    $self->dialog($text, 'error') unless $self->batch;
    croak($self->encoding->encode($text));
}

method info (@msg) {
    my $text = join("\n", @msg);
    say $self->encoding->encode($text);
}

method run_cmd ($args) {
    my @cmd = @{$args->{cmd}};
    if (exists $args->{as} && ! $ENV{HARNESS_ACTIVE}) {
        @cmd = ('sudo', '-n', '-u', $args->{as}, @cmd);
    }
    my ($stdout, $stderr);
    my $success = 1;
    run \@cmd, '>', \$stdout, '2>', \$stderr or $success = 0;
    my $exit_code = $?;
    return ($stdout, $stderr, $success, $exit_code);
}

method fatal_run_cmd ($args) {
    my $error_msg = $args->{error_msg};
    my @cmd       = @{$args->{cmd}};
    my %run_cmd_args;
    $run_cmd_args{as} = $args->{as} if exists $args->{as};
    my ($stdout, $stderr, $success, $exit_code) = $self->run_cmd({
        cmd => \@cmd,
        %run_cmd_args,
    });
    $success or $self->fatal(
        errf("<b>%{error_msg}s</b>\n\n%{debugging_info}s",
             {
                 error_msg      => $error_msg, # was already decoded
                 debugging_info => $self->encoding->decode(errf(
                     "<b>Debugging</b>\n".
                     "<i>exit code</i>: %{exit_code}i\n\n".
                     "<i>stdout:</i>\n%{stdout}s\n\n".
                    "<i>stderr:</i>\n%{stderr}s",
                     {
                         exit_code => $exit_code,
                         stdout    => $stdout,
                         stderr    => $stderr,
                     }
                 )),
             },
         ));
    return ($stdout, $stderr, $success, $exit_code);
}

method dialog ($question, $type) {
    $type //= 'question';
    $self->info($question);
    return 1 if $self->batch;
    system('zenity', "--$type", '--text', $question);
    ${^CHILD_ERROR_NATIVE} == 0;
}

method in_progress ($code, $text) {
    $self->info($text);
    # (Declaring variables in conditional statements is bad practice,
    # even if doing so here would actually be correct and working
    # at the time of the initial writing.)
    my $h;
    $h = start [qw{zenity --info --text}, $text] unless $self->batch;
    $code->();
    $h->kill_kill unless $self->batch;
}

method get_update_description () {
    my @args;
    for (qw{baseurl build_target os_release_file}) {
        my $attribute = "override_$_";
        my $predicate = "has_$attribute";
        if ($self->$predicate) {
            my $arg = "--$attribute"; $arg =~ s{_}{-}xmsg;
            push @args, ($arg, $self->$attribute);
        }
    }
    if ($self->has_override_trusted_gnupg_homedir) {
        push @args, ('--trusted-gnupg-homedir', $self->override_trusted_gnupg_homedir);
    }
    my ($stdout, $stderr, $success, $exit_code) = $self->fatal_run_cmd({
        cmd       => [ 'tails-iuk-get-update-description-file', @args ],
        error_msg => $self->encoding->decode(gettext(
            "Could not determine whether an update is available: ".
            "<a href='file:///usr/share/doc/tails/website/doc/upgrade/error/get_update_description.en.html'>".
            "read more</a>",
    ))});

    return ($stdout, $stderr, $success, $exit_code);
}

method run () {
    my ($update_description_text) = $self->get_update_description;
    my $update_description = Tails::IUK::UpdateDescriptionFile->new_from_text(
        $update_description_text
    );

    unless ($update_description->contains_update_path) {
        $self->info($self->encoding->decode(gettext("The system is up-to-date")));
        exit(0);
    }

    $self->info($self->encoding->decode(gettext(
        'This version of Tails is outdated, and may have security issues.'
    )));
    my ($update_path, $update_type);
    if ($update_description->contains_incremental_update_path) {
        $update_path = $update_description->incremental_update_path;
        $update_type = 'incremental';
    }
    elsif ($update_description->contains_full_update_path) {
        $update_path = $update_description->full_update_path;
        $update_type = 'full';
    }
    else {
        croak "This should not happen. Please report a bug.";
    }

    exit(0) unless($self->dialog(
        errf(
            "You should update to %{name}s %{version}s ".
            "(<a href='%{details_url}s'>details</a>).\n".
            "Do you want to do it now?\n\n".
            "Download size: %{size}s",
            {
                details_url => $update_path->{'details-url'},
                name        => $update_description->product_name,
                version     => $update_path->{version},
                size        => format_bytes($update_path->{'total-size'},
                                            mode => "iec"),
            }),
        'question'));

    if ($update_type eq 'incremental') {
        $self->do_incremental_update($update_path);
    }
    else {
        $self->do_full_update($update_path);
    }
}

sub target_files {
    my $update_path = shift;
    my $destdir     = shift;

    assert(defined $update_path);
    assert(defined $destdir);

    my @target_files;
    foreach my $target_file (@{$update_path->{'target-files'}}) {
        my $basename    = file($target_file->{url})->basename;
        my $output_file = file($destdir, $basename);
        push @target_files,
            {
                %{$target_file},
                output_file => $output_file,
            };
    }

    return @target_files;
}

method get_target_files ($update_path, $destdir) {
    foreach my $target_file (target_files($update_path, $destdir)) {
        my @cmd = (
            'tails-iuk-get-target-file',
            '--uri',         $target_file->{url},
            '--hash-type',   'sha256',
            '--hash-value',  $target_file->{sha256},
            '--size',        $target_file->{size},
            '--output-file', $target_file->{output_file},
        );
        $self->fatal_run_cmd({
            cmd       => \@cmd,
            error_msg => $self->encoding->decode(errf(
                gettext(
                    q{Failed to download from %{target_url}s: }.
                    q{<a href='file:///usr/share/doc/tails/website/doc/upgrade/error/get_target_file.en.html'>read more</a>},
                ),
                {
                    target_url => $target_file->{url},
                }
            )),
            as        => 'tails-iuk-get-target-file',
        });
        -e $target_file->{output_file} or $self->fatal(
            $self->encoding->decode(errf(
                gettext(
                    q{Output file '%{output_file}s' does not exist, but }.
                    q{tails-iuk-get-target-file did not complain. }.
                    q{Please report a bug.}
                ),
            { output_file => $target_file->{output_file} }
        )));
    }
}

method do_incremental_update ($update_path) {
    my ($stdout, $stderr, $success, $exit_code);

    my ($target_files_tempdir) = $self->fatal_run_cmd({
        cmd       => ['tails-iuk-mktemp-get-target-file'],
        error_msg => $self->encoding->decode(gettext(
            "Failed to create temporary download directory"
        )),
        as        => 'tails-iuk-get-target-file',
    });
    chomp $target_files_tempdir;

    $self->in_progress(
        sub { $self->get_target_files($update_path, $target_files_tempdir) },
        $self->encoding->decode(errf(
            gettext(
                "Downloading the update for %{name}s %{version}s, please wait."
            ),
            {
                name        => $self->product_name,
                version     => $update_path->{version},
            }
        ))
    );

    $self->in_progress(
        sub { $self->install_iuk($update_path, $target_files_tempdir) },
        $self->encoding->decode(gettext(
            "The system is now being updated, please wait.\n".
            "Note: for safety reasons, the network connection is disabled ".
            "during the update."
        ))
    );

    $self->dialog(
        $self->encoding->decode(gettext(
            "<b>The system was successfully updated.</b>\n\n".
            "The Tails partition on the USB stick is not write-protected anymore for this working session.\n".
            "This is not safe, and you should restart Tails <b>as soon as possible</b>.\n\n".
            "Shutdown the computer <i>now</i>?"
        )),
        'question'
    ) && $self->shutdown_system;

    exit(0);
}

method shutdown_system {
    $self->info("Shutting down the system");
    $self->fatal_run_cmd({
        cmd       => ['/sbin/halt'],
        error_msg => $self->encoding->decode(gettext(q{Failed to halt the system})),
        as        => 'root',
    }) unless $ENV{HARNESS_ACTIVE};
}

method do_full_update ($update_path) {
    my $url = $update_path->{'details-url'};
    if ($ENV{HARNESS_ACTIVE}) {
        $self->info("Opening $url in web browser");
        exit(0);
    }
    else {
        exec('iceweasel', $url);
    }
}

method shutdown_network {
    $self->info("Shutting down network connection");
    $self->fatal_run_cmd({
        cmd       => ['tails-shutdown-network'],
        error_msg => $self->encoding->decode(gettext(q{Failed to shutdown network})),
        as        => 'root',
    }) unless $ENV{HARNESS_ACTIVE};
}

method install_iuk ($update_path, $target_files_tempdir) {
    assert(defined $update_path);
    assert(defined $target_files_tempdir);

    $self->shutdown_network;

    my @target_files = target_files($update_path, $target_files_tempdir);
    assert(@target_files == 1);

    my @args;
    push @args, ('--liveos-mountpoint', $self->liveos_mountpoint)
        if $self->has_liveos_mountpoint;
    $self->fatal_run_cmd({
        cmd       => [
            'tails-install-iuk',
            @args,
            $target_files[0]->{output_file}
        ],
        error_msg => $self->encoding->decode(gettext(
            q{Failed to install update :}.
            q{<a href='file:///usr/share/doc/tails/website/doc/upgrade/error/install_iuk.en.html'>}.
            q{read more</a>},
        )),
        as        => 'tails-install-iuk',
    });
}

no Moose;
1;
