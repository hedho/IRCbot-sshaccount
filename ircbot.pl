#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;

my $server = "irc.ircnow.org";
my $port = 6667;
my $nick = "monSSH";
my $username = "shell_bot";
my $realname = "Shell Account Bot";
my $channel = "#debian";

# Connect to IRC server
my $socket = IO::Socket::INET->new(
    PeerAddr => $server,
    PeerPort => $port,
    Proto => 'tcp'
) or die "Could not connect to IRC server\n";

# Send login information
print $socket "NICK $nick\r\n";
print $socket "USER $username 0 * :$realname\r\n";

while (my $input = <$socket>) {
    chomp $input;
    print "$input\n";

    if ($input =~ /^PING (.*)/) {
        print $socket "PONG $1\r\n";
    }

print $socket "JOIN $channel\r\n";

    # Check for private message from user
    if ($input =~ /^:(.*)!.*PRIVMSG $nick :!request/) {
        my $nickname = $1;
        # Check if username already exists
        my $username_check = `grep $nickname /etc/passwd`;
        if ($username_check) {
            # Send message to user if username already exists
            print $socket "PRIVMSG $nickname :Username already exists\r\n";
        } else {
            my $math_problem = int(rand(100)) + int(rand(100));
            print $socket "PRIVMSG $nickname :Solve this math problem to create the account: $math_problem = ?\r\n";
            my $answer = <$socket>;
            if ($answer =~ /^:(.*)!.*PRIVMSG $nick :$math_problem/) {
                # Create new shell user account
                my $result = `useradd -m -s /bin/bash  $nickname`;
                # Set password for new user account
                my $password = int(rand(999999));
                `echo $nickname:$password | chpasswd`;
                # Send message to user with username and password information
                print $socket "PRIVMSG $nickname :Your shell account has been created with username: $nickname and password: $password\r\n";
                print $socket "PRIVMSG $nickname :You can connect at you're account using ssh $nickname host realcrew.info port 22 using you're password $password\r\n";
            } else {
                print $socket "PRIVMSG $nickname :Incorrect answer, account creation terminated.\r\n";
            }
        }
    }

    # Check for !help command
    if ($input =~ /^:(.*)!.*PRIVMSG $nick :!help/) {
        my $nickname = $1;
        # Send message to user with instructions on how to request a shell account
        print $socket "PRIVMSG $nickname :To request a shell account, send a private message to me with the command !request\r\n";
    }
}
