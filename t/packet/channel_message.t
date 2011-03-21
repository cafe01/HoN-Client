#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::ChannelMessage' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


# ChannelMessage - received
#Data (13 bytes - len / 13 bytes - buffer):
#  0x0000 : 3E 54 31 00 46 01 00 00 6C 6F 6C 7A 00          : >T1.F...lolz.

my $pkt = $factory->decode_packet(0x0300, pack('H*', '3E543100460100006C6F6C7A00'));
isa_ok($pkt, 'HoN::Client::Chat::Packet::ChannelMessage', 'thing returned by decode_packet()');

is($pkt->account_id, 0x31543E, 'right account_id');
is($pkt->channel_id, 0x0146, 'right channel_id');
is($pkt->message, 'lolz', 'right message');
is($pkt->event_name, 'channel_message_received', 'right event name');

is_deeply($pkt->unpacked, {
    id => 0x0300,
    event_name => 'channel_message_received',
    account_id => 0x31543E,
    channel_id => 0x0146,
    message => 'lolz',
}, 'unpacked');









