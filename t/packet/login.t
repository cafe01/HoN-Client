#!perl 
use strict;
use warnings;
use Test::More;        
use Test::Exception;        
use HoN::Client::Chat::PacketFactory;

plan 'no_plan';

# use
BEGIN {
    use_ok( 'HoN::Client::Chat::Packet::Login' ) || print "Bail out!";
}

# instace
my $factory = HoN::Client::Chat::PacketFactory->new;


# Login
my $pkt_login = $factory->encode_packet('Login', { account_id => 1462544, protocol_version => 0x000c, cookie => '0b88206ad4b6e95a9624fbcd06413c6a'});

isa_ok($pkt_login, 'HoN::Client::Chat::Packet::Login', 'login request- thing returned by encode_packet()');
is(unpack( 'H*', $pkt_login->packed), '000c10511600306238383230366164346236653935613936323466626364303634313363366100000c00000000000000', 'login request - right packed data');
is($pkt_login->event_name, 'login_request', 'login request - right event name');

# login response (success)
$pkt_login = $factory->decode_packet(0x001c, '');
isa_ok($pkt_login, 'HoN::Client::Chat::Packet::Login', 'login response (success) - thing returned by decode_packet()');
is($pkt_login->event_name, 'login_success', 'login response - right event name');

is_deeply($pkt_login->unpacked, {
    id => 0x001c,
    event_name => 'login_success'
}, 'unpacked');











