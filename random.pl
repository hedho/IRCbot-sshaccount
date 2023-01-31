use strict;
use warnings;
use IO::Socket;

my @nicks = qw(jett Bardha Endrita Mirja Omla);

while (1) {
  my $nick = $nicks[rand @nicks];
  my $socket = new IO::Socket::INET (
    PeerAddr => 'irc.shoqni.net',
    PeerPort => 6667,
    Proto => 'tcp',
  );
  
  if ($socket) {
    print $socket "NICK $nick\r\n";
    print $socket "USER $nick 0 * :Vizitor nga Shoqni.com\r\n";
    

    while (my $input = <$socket>) {
      print $input;
      print $socket "JOIN #chat\r\n";
      if ($input =~ /^PING(.*)$/i) {
        print $socket "PONG $1\r\n";
	}
    }

    close $socket;
  }

  sleep 20 * 60;
}
