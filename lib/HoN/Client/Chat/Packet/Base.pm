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


class_has 'name'            => ( is => 'ro', isa => 'Str', default => '' );
class_has 'event_name'      => ( is => 'rw', isa => 'Str', default => '' ); 

class_has 'events'          => ( is => 'ro', isa => 'ArrayRef', default => sub{ [] } ); # all possible events related to this packet 

class_has 'decode_id'       => ( is => 'ro', isa => 'Int', default => '' );
class_has 'encode_id'       => ( is => 'ro', isa => 'Int', default => '' );



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
         'pack'     => 'pack' ,
         'unpack'   => 'unpack' ,
         'parse_c'  => 'parse',
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
typedef char String[];
typedef u_32 account_id;
typedef char cookie[32];

CCODE

    # tags
    $c->tag('cookie', Format => 'String');
    $c->tag('String', Format => 'String');
    $c->tag('account_id', ByteOrder => 'LittleEndian');

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




sub _dump {
    my ($self, $data) = @_;
    print STDERR hexdump(data => $data);
}



__PACKAGE__->meta()->make_immutable();

1;

















