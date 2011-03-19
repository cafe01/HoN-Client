#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::UserUpdate' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;

# UserUpdate

#  Data (31 bytes - len / 31 bytes - buffer):
#  0x0000 : BE 3C 03 00 03 00 00 00 00 00 00 76 65 6E 65 7A : .<.........venez
#  0x0010 : 75 65 6C 61 00 77 68 69 74 65 00 48 61 70 70 79 : uela.white.Happy
#  0x0020 : 20 46 61 63 65 00                               : .Face.

# BE3C03000300000000000076656E657A75656C61007768697465004861707079204661636500

my $pkt_uu = $factory->decode_packet(0x0c00, pack( 'H*', 'BE3C03000341000000000076656E657A75656C61007768697465004861707079204661636500'));
isa_ok($pkt_uu, 'HoN::Client::Chat::Packet::UserUpdate', 'UserUpdate - thing returned by decode_packet()');

# main attributes
is($pkt_uu->account_id, 0x00033CBE, 'UserUpdate - account_id');
is($pkt_uu->state, 0x03, 'UserUpdate - state');
is($pkt_uu->flags, 0x41, 'UserUpdate - flags');
is($pkt_uu->clan, '', 'UserUpdate - clan');
is($pkt_uu->symbol, 'venezuela', 'UserUpdate - symbol');
is($pkt_uu->color, 'white', 'UserUpdate - color');
is($pkt_uu->icon, 'Happy Face', 'UserUpdate - icon');

# decoded state
is($pkt_uu->online, 1, 'UserUpdate - state - online');
is($pkt_uu->in_game, 0, 'UserUpdate - state - in_game');
is($pkt_uu->in_lobby, 0, 'UserUpdate - state - in_lobby');

# decoded flags
is($pkt_uu->is_moderator, 1, 'UserUpdate - flag - is_moderator');
is($pkt_uu->is_founder, 0, 'UserUpdate - flag - is_founder');
is($pkt_uu->is_prepurchased, 1, 'UserUpdate - flag - is_prepurchased');








