#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::PlayerJoinedChannel' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


# Player Joined Channel
#  0x0000 : 48 61 77 6B 65 65 00 12 60 2F 00 83 06 00 00 03 : Hawkee..`/......
#  0x0010 : 00 75 6E 69 74 65 64 6B 69 6E 67 64 6F 6D 00 77 : .unitedkingdom.w
#  0x0020 : 68 69 74 65 00 54 68 65 20 48 61 77 6B 00       : hite.The.Hawk.

# 4861776B65650012602F00830600000300756E697465646B696E67646F6D00776869746500546865204861776B00

my $data =  '4861776B65650012602F00830600000300756E697465646B696E67646F6D00776869746500546865204861776B00';
my $pkt = $factory->decode_packet(0x0500, pack('H*', $data));

isa_ok($pkt, 'HoN::Client::Chat::Packet::PlayerJoinedChannel', 'thing returned by encode_packet()');

is($pkt->channel_id, 0x00000683, "channel_id");


is_deeply($pkt->user, {
  'account_id' => 3104786,
  'nickname' => 'Hawkee',
  'color' => 'white',
  'symbol' => 'unitedkingdom',
  'icon' => 'The Hawk',
  'flags' => {
               'is_prepurchased' => 0,
               'is_moderator' => 0,
               'is_founder' => 0
             },
  'state' => {
               'in_game' => 0,
               'in_lobby' => 0,
               'online' => 1
             }
}, "user hashref");


is_deeply($pkt->unpacked, {
  'id'         => 0x0500,
  'event_name' => 'player_joined_channel',
  'channel_id' => 1667,
  'user' => {
              'account_id' => 3104786,
              'nickname' => 'Hawkee',
              'color' => 'white',
              'symbol' => 'unitedkingdom',
              'icon' => 'The Hawk',
              'flags' => {
                           'is_prepurchased' => 0,
                           'is_moderator' => 0,
                           'is_founder' => 0
                         },
              'state' => {
                           'in_game' => 0,
                           'in_lobby' => 0,
                           'online' => 1
                         }
            },
}, "unpacked");








