package HoN::Client::Chat::Packet::PlayerJoinedChannel;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';


=head1 NAME

HoN::Client::Chat::Packet::PlayerJoinedChannel - PlayerJoinedChannel packet.

=head1 VERSION

See HoN::Client

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, plus:
 - channel_id
 - user

=cut

class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'PlayerJoinedChannel' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ player_joined_channel /]} );
class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x0500 );

has 'event_name'  => ( is => 'rw', isa => 'Str'  );

has 'channel_id'  => ( is => 'rw', isa => 'Int'  );
has 'user'  => ( is => 'rw', isa => 'HashRef'  );


sub _decode_packet {
    my ($self) = @_;    

#    STRING: nickname 
#    DWORD: account id 
#    DWORD: channel id 
#    BYTE: state 
#    BYTE: flags 
#    STRING: symbol 
#    STRING: color 
#    STRING: icon

    # raw bits
    my $data = $self->decode_data;
    
    # unpack 
    my %user;
    my %unpacked = (
        id      => $self->decode_id,
        user  => \%user
    ); 
    
    my $pos = 0;
        
    # STRING: nickname
    $user{nickname} = unpack('Z*', substr $data, $pos);
    $pos += length($user{nickname}) + 1; 

     # DWORD: account_id
    $user{account_id} = unpack('I<', substr $data, $pos);  
    $pos += 4;
    
     # DWORD: channel_id
    $unpacked{channel_id} = unpack('I<', substr $data, $pos); 
    $pos += 4;
       
#    BYTE: state 
    $user{state} = $self->_decode_user_state( unpack('C', substr $data, $pos) );
    $pos++; 
    
#    BYTE: flags 
    $user{flags} = $self->_decode_user_flags( unpack('C', substr $data, $pos) );
    $pos++; 
    
#    STRING: symbol 
    $user{symbol} = unpack('Z*', substr $data, $pos);
    $pos += length($user{symbol}) + 1; 

#    STRING: color 
    $user{color} = unpack('Z*', substr $data, $pos);
    $pos += length($user{color}) + 1; 

#    STRING: icon   
    $user{icon} = unpack('Z*', substr $data, $pos);
    $pos += length($user{icon}) + 1; 
       
       
#    use Data::Dumper;
#    print STDERR Dumper(\%unpacked);
    
    # populate attributes
    $self->$_($unpacked{$_}) for keys %unpacked;
    
    # save unpacked struct
    $self->unpacked(\%unpacked);
        
    # evt name
    $self->event_name('player_joined_channel');

}


1;










