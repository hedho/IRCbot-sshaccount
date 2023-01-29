#!/usr/bin/perl
use warnings;
use strict;
use POE;
use POE::Component::IRC;

my $irc = POE::Component::IRC->spawn(
   nick => "messengerz",
   server => "irc.ircnow.org",
   port => 6667,
   ircname => "monSSH Bot",
);

POE::Session->create(
   package_states => [
      main => [qw(_start irc_001 irc_public)],
   ],
);

$poe_kernel->run();

sub _start {
   $irc->yield(register => "all");
   $irc->yield(connect => {});
   return;
}

sub irc_001 {
   my $sender = $_[SENDER];
   $irc->yield(join => "#debian");
   return;
}

sub irc_public {
   my ($sender, $who, $where, $what) = @_[SENDER, ARG0 .. ARG2];
   my $nick = (split /!/, $who)[0];
   my $channel = $where->[0];

   if ($what =~ /^!help/) {
      $irc->yield(privmsg => $channel => "Please for more information Private message /query monSSH !help");
   } elsif ($what =~ /^!info/) {
      $irc->yield(privmsg => $channel => "Information: The server is running okay !");
   } elsif ($what =~ /^!shqip/) {
      $irc->yield(privmsg => $channel => "Informatat ne shqipe jane akoma nen perpunim !");
   }
   return;
}
