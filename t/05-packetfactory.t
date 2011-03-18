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
my $pkt = $factory->decode_packet(0x9999,  pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'));

isa_ok($pkt, 'HoN::Client::Chat::Packet', 'thing returned by decode_packet()');

is($pkt->id, 39321, 'right packet id');
is($pkt->binary_data, pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'), 'right packet data');









