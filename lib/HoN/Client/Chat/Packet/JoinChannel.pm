package HoN::Client::Chat::Packet::JoinChannel;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';



class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'JoinChannel' );

class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ join_channel /]} );  

class_has 'encode_id'   => ( is => 'ro', isa => 'Int', default => 0x1e00 );

has 'event_name'  => ( is => 'ro', isa => 'Str', default => 'join_channel' );


# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
    $c->parse(<<'CCODE');
    
struct JoinChannel {
    u_16 id;
    char channel[];
};
CCODE

    # tag    
    $c->tag('JoinChannel.channel', Format => 'String');
    
    # return
    return $c;
};



sub _encode_packet {
    my ($self) = @_;
    
    my $data = $self->encode_data;
    
    # required fields
    for (qw/ channel /) {
        die "Packet needs '$_' field." unless exists $data->{$_};
    }

    # add packet fields
    $data->{id} = $self->encode_id;
    
    # pack
    return $self->packed( $self->pack($self->name, $data) );
}



1;