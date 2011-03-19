#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;       
use HoN::Client::Chat::PacketFactory; 

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::Whisper' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


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









