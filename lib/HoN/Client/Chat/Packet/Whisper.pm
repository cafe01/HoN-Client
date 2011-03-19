package HoN::Client::Chat::Packet::Whisper;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';



class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'Whisper' );
class_has 'events'       => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ whisper_sent whisper_received /]} );

class_has 'decode_id'  => ( is => 'ro', isa => 'Int', default => 0x0800 );
class_has 'encode_id'  => ( is => 'ro', isa => 'Int', default => 0x0800 );

has 'user'  => ( is => 'rw', isa => 'Str', default => '' );
has 'message'  => ( is => 'rw', isa => 'Str', default => '' );

# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
#    ID: 0x0800
#    STRING: user 
#    STRING: message 
     
    $c->parse(<<'CCODE');
        
struct Whisper {
    u_16 id;
    ConcatString user;
    ConcatString message;
};

CCODE

    # return
    return $c;
};



sub _encode_packet {
    my ($self) = @_;    
    
    # data
    my $data    = $self->encode_data;
    $data->{id} = $self->encode_id;
    
    # pack
    $self->packed( $self->pack($self->name, $data) );    
    #$self->_dump;
    
    # populate attributes
    $self->$_($data->{$_}) for (qw/ user message /);   
    
    # evt name
    $self->event_name('whisper_sent');
}




sub _decode_packet {
    my ($self) = @_;    
    
    # raw bits
    my $data = $self->decode_data;
    
    # unpack   (stuff the id back into data, so share the same C struct as encoder)
    my $unpacked = $self->unpack($self->name,  pack('S>', $self->decode_id).$data);
    
    # populate attributes
    $self->$_($unpacked->{$_}) for (qw/ user message /);       
    
    # evt name
    $self->event_name('whisper_received');
}
















1;