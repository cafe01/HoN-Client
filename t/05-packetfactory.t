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

# unknown packet
my $pkt = $factory->decode_packet(0x8888,  pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'));
isa_ok($pkt, 'HoN::Client::Chat::Packet::UnknownPacket', 'thing returned by decode_packet()');

is($pkt->id, 0x8888, 'right packet id');
is($pkt->decode_data, pack( 'H*', '5B724B725D4E6575726F626173686572004D414E44414E444F205748495350455200'), 'right packet data');






