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

isa_ok($pkt_login, 'HoN::Client::Chat::Packet::Login', 'thing returned by encode_packet()');


is($pkt_login->packed, pack( 'H*', '000C10511600306238383230366164346236653935613936323466626364303634313363366100000B00000000000000'), 'Login - right packed data');










