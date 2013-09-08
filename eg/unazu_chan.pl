#!/usr/bin/env perl
use 5.010;
use warnings;
use utf8;

use UnazuChan;

my $unazu_chan = UnazuChan->new(
    active_chats => ['#anappo2/$d936403094338dbb'],
    respond_all  => 1,
);

$unazu_chan->on_message(
    qr/^\s*unazu_chan:/ => sub {
        my $msg = shift;
        $msg->chat->send_message('うんうん');
    },
    qr/(.)/ => sub {
        my ($msg, $match) = @_;
        say $match;
        say $msg->body;
    },
);

$unazu_chan->on_command(
    help => sub {
        my ($body, @args) = @_;
        warn;
        $body->chat->send_message('help '. ($args[0] || ''));
    }
);

$unazu_chan->run;
