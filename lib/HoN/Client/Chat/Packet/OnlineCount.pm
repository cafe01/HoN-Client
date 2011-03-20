package HoN::Client::Chat::Packet::OnlineCount;

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

- count: online players count

=cut


class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'OnlineCount' );
class_has 'events'       => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ online_count /]} );

class_has 'decode_id'  => ( is => 'ro', isa => 'Int', default => 0x6800 );

has 'count'  => ( is => 'rw', isa => 'Int' );

# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
#    ID: 0x6800
#    DWORD: count  
     
    $c->parse(<<'CCODE');
        
struct OnlineCount {
    dword count;
};

CCODE

    # return
    return $c;
};




sub _decode_packet {
    my ($self) = @_;    
    
    # raw bits
    my $data = $self->decode_data;
    
    # unpack 
    my $unpacked = $self->unpack($self->name,  $data);
    
    # populate attributes
    $self->$_($unpacked->{$_}) for (qw/ count /);       
        
    # evt name
    $self->event_name('online_count');
}
















1;