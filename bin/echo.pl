#!/usr/bin/perl -w
use strict;

use IO::Socket::IP;

my $port = int(shift || 0);

my $listen = IO::Socket::IP->new(LocalPort => $port, Listen => 1) or die "Listen: $@";
warn $listen->sockport,"\n";
my $socket = $listen->accept or die "Accept: $!";

while ($socket->read($_, 1)) { $socket->write($_); }
