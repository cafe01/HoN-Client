package HoN::Client::Chat::Packet::Login;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';


=head1 NAME

HoN::Client::Chat::Packet::Login - Login packet, send and receive.

=head1 VERSION

See HoN::Client.

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, none added.

=cut

class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'Login' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ login_request login_success /]} );

class_has 'encode_id'   => ( is => 'ro', isa => 'Int', default => 0x000c );
class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x001c );

has 'event_name'  => ( is => 'rw', isa => 'Str', default => 'login_request' );

# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
    $c->parse(<<'CCODE');
    
struct Login {
    u_16 id;
    account_id account_id;
    cookie cookie;
    char padding[10];
};
CCODE

    # tag    
    #$c->tag('Login.account_id', ByteOrder => '');
    
    # return
    return $c;
};



sub _encode_packet {
    my ($self) = @_;
    
    my $data = $self->encode_data;
    
    # required fields
    for (qw/ cookie account_id /) {
        die "Packet needs '$_' field." unless exists $data->{$_};
    }

    # add packet fields
    $data->{id} = $self->encode_id;
    $data->{padding} = [0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
    
    # pack
    return $self->packed( $self->pack($self->name, $data) );
}



sub _decode_packet {
    my ($self) = @_;    
    # the login success packet has only an ID, no data
    
    # set event name to "login_success"
    $self->event_name('login_success');
    
}



1;