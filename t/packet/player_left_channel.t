#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::PlayerLeftChannel' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;

# Player Left Channel
#  0x0000 : F3 45 01 00 83 06 00 00                         : .E......

# F345010083060000
my $pkt = $factory->decode_packet(0x0600, pack('H*', 'F345010083060000'));

isa_ok($pkt, 'HoN::Client::Chat::Packet::PlayerLeftChannel', 'thing returned by encode_packet()');


is($pkt->event_name, 'player_left_channel', "event_name");
is($pkt->account_id, 0x000145F3, "account_id");
is($pkt->channel_id, 0x00000683, "channel_id");








