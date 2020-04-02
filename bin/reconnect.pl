#!/usr/bin/perl -w
use strict;

use IO::Socket::IP;

use FileHandle;

my $targetport = int(shift || 0);
my $targethost = shift || 'localhost';
my $listenport = int(shift || 0);


my $listen = IO::Socket::IP->new(LocalPort => $listenport, Listen => 1) or die "Listen: $@";
warn $listen->sockport,"\n";

my $target = IO::Socket::IP->new(PeerHost => $targethost, PeerPort => $targetport, Type => SOCK_STREAM) 
    or die "Connect($targethost:$targetport): $@"; 

my $last = '';
while (my $client = $listen->accept) {
    my $password;
    $client->read($password, 5);
    if ($password =~ /^(.)hysj$/) {
	my $do = $1;
	last if ($do eq 'X');
	if ($do eq 'R') {
	    kill(15, $last);
	}
    }
    else {
	$client->shutdown(2);
	next;
    }
    if (my $pid = fork()) {
	warn "Spawned $pid, last: $last\n";
	$last = $pid;
    }
    else {
	warn "$$ starting...\n";
	while ($client->read($_, 1)) { 
	    warn "$$ $_\n"; 
	    $target->write($_); 
	}
	warn "$$ exit\n";
	exit;
    }
}
die "Accept: $!"


__END__







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
