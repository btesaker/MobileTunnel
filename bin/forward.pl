#!/usr/bin/perl -w
use strict;

use IO::Socket::IP;

use FileHandle;

my $targetport = int(shift || 0);
my $targethost = shift || 'localhost';
my $listenport = int(shift || 0);

my $target = IO::Socket::IP->new(PeerHost => $targethost, PeerPort => $targetport, Type => SOCK_STREAM) 
    or die "Connect($targethost:$targetport): $@"; 
warn "Connected:";

my $listen = IO::Socket::IP->new(LocalPort => $listenport, Listen => 1) or die "Listen: $@";
warn $listen->sockport,"\n";
my $client = $listen->accept or die "Accept: $!";

my $pid = fork;
my ($in, $out, $dir);
if ($pid) {
    $in = $client;
    $out = $target;
    $dir = ">";
}
else {
    $in = $target;
    $out = $client;
    $dir = "<";
}
while ($in->read($_, 1)) { warn "$dir$_\n"; $out->write($_); }
$out->shutdown;
$in->shutdown;
