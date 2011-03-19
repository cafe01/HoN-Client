#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::PacketFactory' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;

# decode packet (whisper)
#  0x0000 : 5B 72 4B 72 5D 4E 65 75 72 6F 62 61 73 68 65 72 : [rKr]Neurobasher
#  0x0010 : 00 4D 41 4E 44 41 4E 44 4F 20 57 48 49 53 50 45 : .MANDANDO.WHISPE
#  0x0020 : 52 00      

#my $pkt = $factory->decode_packet(0x0800,  pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'));

# unknown packet
my $pkt = $factory->decode_packet(0x8888,  pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'));
isa_ok($pkt, 'HoN::Client::Chat::Packet::UnknownPacket', 'thing returned by decode_packet()');

is($pkt->id, 0x8888, 'right packet id');
is($pkt->decode_data, pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'), 'right packet data');


# Login
my $pkt_login = $factory->encode_packet('Login', { account_id => 1462544, cookie => '0b88206ad4b6e95a9624fbcd06413c6a'});

isa_ok($pkt_login, 'HoN::Client::Chat::Packet::Login', 'login request- thing returned by encode_packet()');
is($pkt_login->packed, pack( 'H*', '000C10511600306238383230366164346236653935613936323466626364303634313363366100000B00000000000000'), 'login request - right packed data');
is($pkt_login->event_name, 'login_request', 'login request - right event name');

# login response (success)
$pkt_login = $factory->decode_packet(0x001c, '');
isa_ok($pkt_login, 'HoN::Client::Chat::Packet::Login', 'login response (success) - thing returned by decode_packet()');
is($pkt_login->event_name, 'login_success', 'login response - right event name');



# JoinChannel
my $pkt_join = $factory->encode_packet('JoinChannel', { channel => 'Cambada' });

isa_ok($pkt_join, 'HoN::Client::Chat::Packet::JoinChannel', 'JoinChannel - thing returned by encode_packet()');
is($pkt_join->packed, pack( 'H*', '1e0043616d6261646100'), 'JoinChannel - right packed data');



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



# Whisper - encode
#  0x0000 : 5B 72 4B 72 5D 4E 65 75 72 6F 62 61 73 68 65 72 : [rKr]Neurobasher
#  0x0010 : 00 4D 41 4E 44 41 4E 44 4F 20 57 48 49 53 50 45 : .MANDANDO.WHISPE
#  0x0020 : 52 00    

#5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200

my $pkt_whisper = $factory->encode_packet('Whisper', { user => '[rKr]Neurobasher', message => 'MANDANDO WHISPER' });
isa_ok($pkt_whisper, 'HoN::Client::Chat::Packet::Whisper', 'Whisper - thing returned by encode_packet()');

is(unpack('H*', $pkt_whisper->packed),  lc '08005B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200', 'Whisper - encode - packed');
is($pkt_whisper->user, '[rKr]Neurobasher', 'Whisper - encode - user');
is($pkt_whisper->message, 'MANDANDO WHISPER', 'Whisper - encode - message');


# Whisper - decode
#  0x0000 : 5B 72 4B 72 5D 4E 65 75 72 6F 62 61 73 68 65 72 : [rKr]Neurobasher
#  0x0010 : 00 4D 41 4E 44 41 4E 44 4F 20 57 48 49 53 50 45 : .MANDANDO.WHISPE
#  0x0020 : 52 00    

#5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200

$pkt_whisper = $factory->decode_packet(0x0800, pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'));
isa_ok($pkt_whisper, 'HoN::Client::Chat::Packet::Whisper', 'Whisper - thing returned by decode_packet()');

is($pkt_whisper->user, '[rKr]Neurobasher', 'Whisper - user');
is($pkt_whisper->message, 'MANDANDO WHISPER', 'Whisper - message');









