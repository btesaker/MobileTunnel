#!/usr/bin/perl -w
use strict;

use IO::Socket::IP;

my $port = int(shift || 0);
my $host = shift || 'localhost';



my $emit = IO::Socket::IP->new(PeerPort => $port, PeerHost => $host) or die "Emit: $@";

my $expect = 0;
while (1) {
    my $message = '';
    foreach (1 .. int(rand(10)+1)) {
	$message .= "$expect";
	$expect = ++$expect % 10;
    }
    $emit->write($message);
    sleep(int(rand(5)+1));
}
