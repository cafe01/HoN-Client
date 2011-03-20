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

#Got packet: 125 bytes: Packet ID: 0x0c00
#Data (123 bytes - len / 123 bytes - buffer):
#  0x0000 : A2 1A 03 00 05 00 00 00 00 00 00 00 73 69 6C 76 : ............silv
#  0x0010 : 65 72 73 68 69 65 6C 64 00 48 65 61 72 74 20 4A : ershield.Heart.J
#  0x0020 : 61 70 61 6E 00 31 37 34 2E 33 36 2E 32 32 34 2E : apan.174.36.224.
#  0x0030 : 37 30 3A 31 31 32 33 37 00 54 4D 4D 20 4D 61 74 : 70:11237.TMM.Mat
#  0x0040 : 63 68 20 23 39 35 37 33 37 38 00 2E F6 FC 01 01 : ch.#957378......
#  0x0050 : 01 50 69 61 62 61 00 55 53 45 00 6E 6F 72 6D 61 : .Piaba.USE.norma
#  0x0060 : 6C 00 05 63 61 6C 64 61 76 61 72 00 01 00 00 00 : l..caldavar.....
#  0x0070 : 00 00 01 00 00 00 00 00 00 00 00                : ...........


# String: server address
# String: game name
# 6 bytes
# String: Piaba (oq eh isso?)
# String: region (USE)
# String: mode (normal)
# String: map (caldavar)


# A21A0300050000000000000073696C766572736869656C64004865617274204A6170616E003137342E33362E3232342E37303A313132333700544D4D204D617463682023393537333738002EF6FC010101506961626100555345006E6F726D616C000563616C646176617200010000000000010000000000000000

my $pkt_uu = $factory->decode_packet(0x0c00, pack( 'H*', 'A21A0300050000000000000073696C766572736869656C64004865617274204A6170616E003137342E33362E3232342E37303A313132333700544D4D204D617463682023393537333738002EF6FC010101506961626100555345006E6F726D616C000563616C646176617200010000000000010000000000000000'));
isa_ok($pkt_uu, 'HoN::Client::Chat::Packet::UserUpdate', 'UserUpdate - thing returned by decode_packet()');

# main attributes
is($pkt_uu->account_id, 0x00031aa2, 'UserUpdate - account_id');
is($pkt_uu->state, 0x05, 'UserUpdate - state');
is($pkt_uu->flags, 0x00, 'UserUpdate - flags');
is($pkt_uu->clan, '', 'UserUpdate - clan');
is($pkt_uu->symbol, '', 'UserUpdate - symbol');
is($pkt_uu->color, 'silvershield', 'UserUpdate - color');
is($pkt_uu->icon, 'Heart Japan', 'UserUpdate - icon');

# decoded state
is($pkt_uu->online, 0, 'UserUpdate - state - online');
is($pkt_uu->in_game, 1, 'UserUpdate - state - in_game');
is($pkt_uu->in_lobby, 1, 'UserUpdate - state - in_lobby');

# decoded flags
is($pkt_uu->is_moderator, 0, 'UserUpdate - flag - is_moderator');
is($pkt_uu->is_founder, 0, 'UserUpdate - flag - is_founder');
is($pkt_uu->is_prepurchased, 0, 'UserUpdate - flag - is_prepurchased');








