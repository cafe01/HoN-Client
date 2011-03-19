package HoN::Client::Chat::PacketFactory;

use Moose;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;
use Data::Dumper;
use Module::Pluggable::Object;
use HoN::Client::Chat::Packet::UnknownPacket;

with 'HoN::Client::Role::Logger';

=head1 NAME

HoN::Client::Chat::PacketFactory - A packet factory for HoN Chat client.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

=head1 ATTRIBUTES

=cut



has '_default_packet_class' => ( is => 'ro', isa => 'Str', default => 'HoN::Client::Chat::Packet::UnknownPacket' );


has '_decoders' => ( is => 'rw', isa => 'HashRef' );
has '_encoders' => ( is => 'rw', isa => 'HashRef' );


sub BUILD {
    my ($self) = @_;
    
    # build _encoders/_decoders 
        
    my $decoders = {};
    my $encoders = {};
        
    # search namespace
    my $finder = Module::Pluggable::Object->new(search_path => ['HoN::Client::Chat::Packet'], except => 'HoN::Client::Chat::Packet::Base'); 
    foreach my $packet_class ($finder->plugins) {
        $self->log->debug("Found packet class: $packet_class");
        
        #load class
        Class::MOP::load_class($packet_class);
        
        $decoders->{$packet_class->decode_id} = $packet_class if $packet_class->can('_decode_packet'); # map by packet id
        $encoders->{$packet_class->name}      = $packet_class if $packet_class->can('_encode_packet'); # map by packet name
    }
    
    # set
    $self->_decoders($decoders);
    $self->_encoders($encoders);
}




sub encode_packet {
    my ($self, $pkt_name, $data) = @_;
        
    # get encoder
    my $packet_class = $self->get_packet_encoder($pkt_name);
    
    # build n return
    $packet_class->new( encode_data => $data );
}


sub decode_packet {
    my ($self, $pkt_id, $data) = @_;
    
    # $pkt_id is numeric (unpacked)
    # $data   binary binary
    
    # get decoder
    my $packet_class = $self->get_packet_decoder($pkt_id);
    
    # build n return
    $packet_class->new( id => $pkt_id, decode_data => $data );
}


sub get_packet_encoder {
    my ($self, $pkt_name) = @_;    
    return $self->_encoders->{$pkt_name} ? $self->_encoders->{$pkt_name} : $self->_default_packet_class;
}


sub get_packet_decoder {
    my ($self, $pkt_id) = @_;    
    return $self->_decoders->{$pkt_id} ? $self->_decoders->{$pkt_id} : $self->_default_packet_class;
}
























1;
