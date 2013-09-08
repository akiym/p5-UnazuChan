# NAME

UnazuChan - Skype reaction bot framework

# SYNOPSIS

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

# DESCRIPTION

UnazuChan is Skype reaction bot framework.

__THE SOFTWARE IS ALPHA QUALITY. API MAY CHANGE WITHOUT NOTICE.__

# SEE ALSO

[Skype::Any](http://search.cpan.org/perldoc?Skype::Any)

# THANKS TO

Masayuki Matsuki (songumu)

# LICENSE

Copyright (C) Takumi Akiyama.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

Takumi Akiyama <t.akiym@gmail.com>
