package HoN::Client::Chat::PacketFactory;

use Moose;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;
use Data::Dumper;
use Module::Pluggable::Object;
use HoN::Client::Chat::Packet;

with 'HoN::Client::Role::Logger';

=head1 NAME

HoN::Client::Chat::PacketFactory - A packet factory for HoN Chat client.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

=head1 ATTRIBUTES

=cut



has '_default_packet_class' => ( is => 'ro', isa => 'Str', default => 'HoN::Client::Chat::Packet' );


has '_decoders' => ( is => 'ro', isa => 'HashRef', lazy_build => 1 );




sub _build__decoders {
    my ($self) = @_;
    
    $self->log->debug("Searching for packet decoders.");
    
    my $decoders = {};
        
    # search namespace
    my $finder = Module::Pluggable::Object->new(search_path => ['HoN::Client::Chat::Packet']); 
    foreach my $packet_class ($finder->plugins) {
        $self->log->debug("Found packet class: $packet_class");
    }
    
    #
    return $decoders;    
}





sub decode_packet {
    my ($self, $pkt_id, $data) = @_;
    
    # $pkt_id is numeric (unpacked)
    # $data   binary binary
    
    # get decoder
    my $packet_class = $self->get_packet_decoder($pkt_id);
    
    # build n return
    $packet_class->new( id => $pkt_id, binary_data => $data );
}


sub get_packet_decoder {
    my ($self, $pkt_id) = @_;
    
    return $self->_decoders->{$pkt_id} ? $self->_decoders->{$pkt_id}->{class} : $self->_default_packet_class;
}

sub new_packet {
    my ( $self, $name, $data ) = @_;
    
    # debug   
    $self->log->debug("Building packet: $name");

    # can build this kind of packet?
    die "Cant build '$name' packet. " unless $self->can("_build_packet_$name");

    # build pkt
    my $builder = "_build_packet_$name";
    my $pkt     = $self->$builder($data);

    return $pkt;
}


sub _build_packet_Login {
    my ($self, $data) = @_;

    # parse struct
    $self->parse_c(<<'CCODE');
    
struct PacketLogin {
    byte id;
    byte unknown;
    u_32 account_id;
    cookie cookie;
    char padding[10];
};
CCODE

    # tag    
    $self->binary_c->tag('PacketLogin.account_id', ByteOrder => 'LittleEndian');
    $self->binary_c->tag('cookie', Format => 'String');

    # build
    $data->{padding} = [0x00, 0x00, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00];
    return $self->pack('PacketLogin', $data);
}

























1;
