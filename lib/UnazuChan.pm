package UnazuChan;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

use Skype::Any;

sub new {
    my $class = shift;
    my %args = @_ == 1 ? %{$_[0]} : @_;
    my $self = bless {
        name         => __PACKAGE__,
        nickname     => 'unazu_chan',
        active_chats => [],
        %args,
        _reactions => [],
    }, $class;

    my $connector = sub {
        Skype::Any->new(name => delete $self->{name});
    };
    my $skype = $connector->();
    $self->{skype} = $skype;

    $skype->message_received(sub {
        my ($msg) = @_;
        my $chatname = $msg->chatname;
        if (grep { $_ eq $chatname } @{ $self->{active_chats} }) {
            $self->_respond($msg); # Skype::Any::Object::ChatMessage
        }
    });

    $self;
}

sub on_message {
    my ($self, @jobs) = @_;
    while (my ($reg, $sub) = splice @jobs, 0, 2) {
        push @{ $self->_reactions }, [$reg, $sub];
    }
}

sub on_command {
    my ($self, @jobs) = @_;
    while (my ($command, $sub) = splice @jobs, 0, 2) {
        my $reg = _build_command_reg($self->{nickname}, $command);
        push @{ $self->_reactions }, [$reg, $sub, $command];
    }
}

sub _build_command_reg {
    my ($nick, $command) = @_;

    my $prefix = '^\s*'.quotemeta($nick). '_*[:\s]\s*' . quotemeta($command);
}

sub run {
    my $self = shift;
    $self->{skype}->run;
}

sub respond_all { $_[0]->{respond_all} }

sub _reactions { $_[0]->{_reactions} }

sub _respond {
    my ($self, $msg) = @_;

    my $message = $msg->body;
    $message =~ s/^\s+//; $message =~ s/\s+$//;
    for my $reaction (@{ $self->_reactions }) {
        my ($reg, $sub, $command) = @$reaction;

        if (my @matches = $message =~ $reg) {
            if (defined $command) {
                @matches = _build_command_args($reg, $message);
            }
            $sub->($msg, @matches);
            return unless $self->respond_all;
        }
    }
}

sub _build_command_args {
    my ($reg, $mes) = @_;
    $mes =~ s/$reg//;
    $mes =~ s/^\s+//; $mes =~ s/\s+$//;
    split /\s+/, $mes;
}

1;
__END__

=encoding utf-8

=head1 NAME

UnazuChan - Skype reaction bot framework

=head1 SYNOPSIS

    use 5.010;
    use UnazuChan;
    my $unazu_chan = UnazuChan->new(
        active_chats => ['#anappo2/$d936403094338dbb'],
    );
    $unazu_chan->on_message(
        qr/^unazu_chan:/ => sub {
            my $msg = shift;
            $msg->chat->send_message('うんうん');
        },
        qr/(.)/ => sub {
            my ($msg, $match) = @_;
            say $match;
            say $msg->message;
        },
    );
    $unazu_chan->on_command(
        help => sub {
            my ($msg, @args) = @_;
            $msg->chat->send_message('help '. ($args[0] || ''));
        }
    );
    $unazu_chan->run;

=head1 DESCRIPTION

UnazuChan is Skype reaction bot framework.

B<THE SOFTWARE IS ALPHA QUALITY. API MAY CHANGE WITHOUT NOTICE.>

=head1 SEE ALSO

L<Skype::Any>

=head1 THANKS TO

Masayuki Matsuki (songumu)

=head1 LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Takumi Akiyama E<lt>t.akiym@gmail.comE<gt>

=cut
