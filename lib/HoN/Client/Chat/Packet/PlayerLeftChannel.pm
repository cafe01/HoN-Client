package HoN::Client::Chat::Packet::PlayerLeftChannel;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';


=head1 NAME

HoN::Client::Chat::Packet::PlayerLeftChannel - PlayerLeftChannel packet.

=head1 VERSION

See HoN::Client

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, plus:
 - channel_id
 - account_id

=cut

class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'PlayerLeftChannel' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ player_left_channel /]} );
class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x0600 );

has 'event_name'  => ( is => 'rw', isa => 'Str'  );

has 'account_id'  => ( is => 'rw', isa => 'Int'  );
has 'channel_id'  => ( is => 'rw', isa => 'Int'  );

sub _decode_packet {
    my ($self) = @_;    

#    DWORD: account id 
#    DWORD: channel id 

    # raw bits
    my $data = $self->decode_data;
    
    # unpack 
    my $pos = 0;
    my %unpacked = (
        id      => $self->decode_id,
        event_name => 'player_left_channel',
    ); 
            
     # DWORD: account_id
    $unpacked{account_id} = unpack('I<', substr $data, $pos);  
    $pos += 4;
    
     # DWORD: channel_id
    $unpacked{channel_id} = unpack('I<', substr $data, $pos); 
    $pos += 4;
    
#    use Data::Dumper;
#    print STDERR Dumper(\%unpacked);
    
    # populate attributes
    $self->$_($unpacked{$_}) for keys %unpacked;
    
    # save unpacked struct
    $self->unpacked(\%unpacked);

}


1;










