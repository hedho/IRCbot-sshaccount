#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket::INET;
use IO::Select;

open(my $fh, "<", "nicks.txt") or die "Could not open file: $!";
my @nicknames = <$fh>;
chomp @nicknames;

my @sockets;
my $counter = 0;
my $num_bots = 500;
my $wait_time = 0.2;
my $overall_bot_limit = 500;

foreach my $nick (@nicknames) {
    last if $counter >= $num_bots || $counter >= $overall_bot_limit;
    
    my $socket = IO::Socket::INET->new(
        PeerAddr => 'irc.shoqni.com',
        PeerPort => 6667,
        Proto    => 'tcp',
    );
    
    if (!$socket) {
        next;
    }
    
    push @sockets, $socket;
    print $socket "NICK $nick\r\n";
    print $socket "USER $nick 8 * :$nick\r\n";
    $counter++;
    select(undef, undef, undef, $wait_time);
}

my $select = IO::Select->new(@sockets);

while (1) {
    my @ready = $select->can_read(1);
    foreach my $socket (@ready) {
        my $input = <$socket>;
        if ($input =~ /004/) {
            print $socket "JOIN #test\r\n";
        } elsif ($input =~ /PING :(.*)/) {
            print $socket "PONG :$1\r\n";
        }
    }

    foreach my $socket (@sockets) {
        print $socket "JOIN #chat\r\n";
    }
}
