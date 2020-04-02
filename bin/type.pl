#!/usr/bin/perl -w
use strict;

use IO::Socket::IP;

my $port = int(shift || 0);

my $listen = IO::Socket::IP->new(LocalPort => $port, Listen => 1) or die "Listen: $@";
warn $listen->sockport,"\n";
my $socket = $listen->accept or die "Accept: $!";

my $expect = 0;
while ($socket->read($_, 1)) { 
    next if $_ eq "\r";
    next if $_ eq "\n";
    print "Got '$_'";
    print ", expected '$expect'" unless "$_" eq "$expect";
    print "\n";
    $expect = ++$expect % 10;
}
