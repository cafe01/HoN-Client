#!/usr/bin/perl
use strict;
use warnings;

use LWP::UserAgent;
use PHP::Serialization qw(unserialize);
use Data::Dumper;
use JSON;

my $ua = LWP::UserAgent->new( agent => '' );

#my $r = $ua->get("http://masterserver.hon.s2games.com/client_requester.php?f=autocompleteNicks&nickname=chu");

my $rank = $ARGV[0] || 'ranked';
my $nick = $ARGV[1] || 'cafe';

my $r = $ua->get("http://masterserver.hon.s2games.com/statsRequestRanked.php?nickname=$nick");


my $hon_res = unserialize( $r->decoded_content );

# convert number-like strings to real numbers (json needs so)
for (keys %$hon_res) {
    $hon_res->{$_} = $hon_res->{$_}+0 if $hon_res->{$_} =~ /^\d+\.?\d*$/ ;
}

#printf "\t%s => %s\n", $_, $hon_res->{$_} for sort keys %$hon_res;

print to_json($hon_res, { pretty => 1});

print $hon_res->{avgCreepKills};
 