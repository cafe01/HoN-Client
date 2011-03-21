#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::OnlineCount' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


# OnlineCount

my $pkt = $factory->decode_packet(0x6800, pack('H*', 'AABBCCDD'));
isa_ok($pkt, 'HoN::Client::Chat::Packet::OnlineCount', 'thing returned by decode_packet()');

is($pkt->count, 0xDDCCBBAA, 'right count');
is($pkt->event_name, 'online_count', 'event name');

is_deeply($pkt->unpacked, {
  'id'         => 0x6800,
  'event_name' => 'online_count',
  'count' => 0xDDCCBBAA,
}, "unpacked");

