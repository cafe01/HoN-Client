package  HoN::Client::Chat::Packet;

use Moose;    
use MooseX::ClassAttribute;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;
use Data::Dumper;

with 'HoN::Client::Role::Logger';

=head1 NAME

HoN::Client::Chat::Packet - Base class  for HoN Chat client packets.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Extend this class to implement chat packets.

This class is also used when creating unknown packets.

=head1 ATTRIBUTES

=cut


class_has 'packet_id'       => ( is => 'ro', isa => 'Int' );
class_has 'name'            => ( is => 'ro', isa => 'Str', default => 'UnknownPacket' );
class_has 'event_name'  => ( is => 'ro', isa => 'Str', default => 'unknown_packet' );

has 'id'                => ( is => 'ro', isa => 'Int' );
has 'binary_data' => ( is => 'ro' );

has 'binary_c' => (
    is      => 'ro',
    isa     => 'Convert::Binary::C',
    lazy_build => 1,
    handles => {
         'pack'      => 'pack' ,
         'parse_c' => 'parse',
    }
);


sub _build_binary_c {
    my ($self) = @_;
    
    my $c =  Convert::Binary::C->new( ByteOrder => 'BigEndian' );
    
    # parse struct
    $c->parse(<<'CCODE');
    
typedef char byte;
typedef unsigned short u_16;
typedef unsigned int u_32;
typedef char cookie[32];

CCODE

    return $c;
}




1;

















