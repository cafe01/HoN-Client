package HoN::Client::Chat::Packet::Login;

use Moose;
use Data::Hexdumper qw(hexdump);
extends 'HoN::Client::Chat::Packet::Base';


sub _build_name {  'Login' }

sub _build_event_name {  'login_request' }

sub _build_encode_id {  0x000c }


# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
    $c->parse(<<'CCODE');
    
struct Login {
    u_16 id;
    u_32 account_id;
    cookie cookie;
    char padding[10];
};
CCODE

    # tag    
    $c->tag('Login.account_id', ByteOrder => 'LittleEndian');
    
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



1;