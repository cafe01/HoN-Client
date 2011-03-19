package HoN::Client::Chat::Packet::UnknownPacket;

use Moose;
use MooseX::ClassAttribute;
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
class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'UnknownPacket' );
class_has 'event_name'  => ( is => 'ro', isa => 'Str', default => 'unknown_packet' );

class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ unknown_packet /]} );  

class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x99999999 ); # not uset in this packet (unknown!)  



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















