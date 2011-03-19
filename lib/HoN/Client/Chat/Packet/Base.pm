package  HoN::Client::Chat::Packet::Base;

use Moose;    
use MooseX::ClassAttribute;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;
use Data::Dumper;

=head1 NAME

HoN::Client::Chat::Packet::Base - Base class  for HoN Chat client packets.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Extend this class to implement chat packets.

=head1 CLASS ATTRIBUTES

=cut


class_has 'name'            => ( is => 'ro', isa => 'Str', lazy_build => 1 );
class_has 'event_name'  => ( is => 'ro', isa => 'Str', lazy_build => 1 ); 

class_has 'decode_id'       => ( is => 'ro', isa => 'Int', lazy_build => 1 );
class_has 'encode_id'       => ( is => 'ro', isa => 'Int', lazy_build => 1 );



=head1 CLASS ATTRIBUTES

=cut
has 'id'        => ( is => 'ro', isa => 'Int' );

has 'packed'    => ( is => 'rw' );

has 'decode_data'    => ( is => 'ro', predicate => 'has_decode_data' );
has 'encode_data'    => ( is => 'ro', isa => 'HashRef', predicate => 'has_encode_data' );

has 'binary_c'  => (
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
    
    # parse c code
    $c->parse(<<'CCODE');
    
typedef char byte;
typedef unsigned short u_16;
typedef unsigned int u_32;
typedef char cookie[32];

CCODE

    # tags
    $c->tag('cookie', Format => 'String');   

    return $c;
}




=head1 METHODS

=head2 BUILD

Encode/decode packet data.

=cut
sub BUILD {
    my $self = shift;
        
    # load c code
    
    
    # crap shit?
    die "You can only encode_data or decode_data, not both!" if $self->has_encode_data && $self->has_decode_data;
    
    # encode / decode
    $self->_encode_packet if $self->has_encode_data;
    $self->_decode_packet if $self->has_decode_data;
}




1;

















