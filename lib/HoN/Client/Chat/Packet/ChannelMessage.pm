package HoN::Client::Chat::Packet::ChannelMessage;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';

=head1 NAME

HoN::Client::Chat::Packet::ChannelMessage - ChannelMessage packet, send and receive.

=head1 VERSION

See HoN::Client.

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, plus:

- account_id: account_id of user sending the message
- channel_id: the channel id
- message: message text

=cut


class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'Whisper' );
class_has 'events'       => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ channel_message_sent channel_message_received /]} );

class_has 'decode_id'  => ( is => 'ro', isa => 'Int', default => 0x0300 );
#class_has 'encode_id'  => ( is => 'ro', isa => 'Int', default => 0x0800 );

has 'account_id'  => ( is => 'rw', isa => 'Int' );
has 'channel_id'  => ( is => 'rw', isa => 'Int' );
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
        
struct ChannelMessageReceive {
    u_16 id;
    account_id account_id;
    account_id channel_id;
    String message;
};

CCODE

    # return
    return $c;
};



#sub _encode_packet {
#    my ($self) = @_;    
#    
#    # data
#    my $data     = $self->encode_data;
#    $data->{id} = $self->encode_id;
#    
#    # pack
#    $self->packed( $self->pack($self->name, $data) );    
#    #$self->_dump;
#    
#    # populate attributes
#    $self->$_($data->{$_}) for (qw/ user message /);   
#    
#    # evt name
#    $self->event_name('whisper_sent');
#}




sub _decode_packet {
    my ($self) = @_;    
    
    # raw bits
    my $data = $self->decode_data;
    
    # unpack   (stuff the id back into data, so share the same C struct as encoder)
    my $unpacked = $self->unpack('ChannelMessageReceive',  pack('S>', $self->decode_id).$data);
    $self->unpacked($unpacked);
    
    $unpacked->{id} = $self->decode_id;
    $unpacked->{event_name} = 'channel_message_received';
    
    # populate attributes
    $self->$_($unpacked->{$_}) for keys %$unpacked;
}
















1;