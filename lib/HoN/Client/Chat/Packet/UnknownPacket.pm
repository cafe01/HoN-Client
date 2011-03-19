package HoN::Client::Chat::Packet::UnknownPacket;

use Moose;
use Data::Hexdumper qw(hexdump);
extends 'HoN::Client::Chat::Packet::Base';


=head1 NAME

HoN::Client::Chat::Packet::UnknownPacket - Represents unknown HoN Chat client packets.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

This class is used when creating unknown packets.

=head1 ATTRIBUTES

name : UnknownPacket
event_name : unknown_packet

=cut


# register name and event name
sub _build_name {  'UnknownPacket' }
sub _build_event_name {  'unknown_packet' }


sub _build_decode_id {  0x99999999 } # not uset in this packet (unknown!)  


# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
    
     # parse struct
    $c->parse(<<'CCODE');
    
struct UnknownPacket {
    byte id;
    char data[];
};

CCODE

    # tag    
    $c->tag('UnknownPacket.data', Format => 'String');
    
    # return c
    return $c;
};



sub _decode_packet {
    my ($self) = @_;    
    
    # unknown packet, so nothing to decode
    # packet content stored at 'decode_data' attribute
}


















1;















