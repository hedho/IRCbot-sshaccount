#!/usr/bin/perl

use strict;
use warnings;
use IO::Socket;
use List::Util qw(min);

# Open the file containing a list of nicknames
open(my $fh, "<", "nicks.txt") or die "Can't open file: $!";

# Define the maximum number of bots to connect
my $max_bots = 500;

# Keep track of the number of bots that have connected
my $num_bots = 0;

# Loop through each nickname in the file
while (my $nick = <$fh>) {
  chomp($nick);

  # Limit the number of bots to the maximum defined
  last if $num_bots >= $max_bots;

  # Connect to the IRC server using a new socket for each nickname
  my $socket = IO::Socket::INET->new(
    PeerAddr => "irc.example.com",
    PeerPort => 6667,
    Proto => "tcp",
  ) or die "Can't connect to server: $!";

  # Send the nickname to the server
  print $socket "NICK $nick\r\n";

  # Send the user information to the server
  print $socket "USER $nick 0 * :$nick\r\n";

  # Increment the number of bots that have connected
  $num_bots++;

  # Fork a new process to handle the connection for this bot
  my $pid = fork();
  if (!defined $pid) {
    # Error in fork, so close the socket and continue to the next bot
    close($socket);
    next;
  } elsif ($pid == 0) {
    # Child process: Loop to receive messages from the server and respond to them
    while (1) {
      # Read a line from the socket
      my $line = <$socket>;

      # Check if the line is defined (the socket is still open)
      if (defined $line) {
        # Check if the server is asking for the nickname to be registered
        if ($line =~ /^PING\s*:(.*)/) {
          my $ping = $1;
          print $socket "PONG :$ping\r\n";
        }

        # Check if the server has accepted the nickname
        if ($line =~ /^.* 001 $nick/) {
          # Join the #text channel
          print $socket "JOIN #text\r\n";
        }
      } else {
        # The socket has closed, so break the loop
        last;
      }
    }

    # Close the socket and exit the child process
    close($socket);
    exit(0);
  }
}

# Wait for all child processes to finish
while (wait() != -1) {}

# Close the file
close($fh);
