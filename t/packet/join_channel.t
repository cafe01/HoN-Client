#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::JoinChannel' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


# JoinChannel
my $pkt_join = $factory->encode_packet('JoinChannel', { channel => 'Cambada' });

isa_ok($pkt_join, 'HoN::Client::Chat::Packet::JoinChannel', 'JoinChannel - thing returned by encode_packet()');
is($pkt_join->packed, pack( 'H*', '1e0043616d6261646100'), 'JoinChannel - right packed data');

