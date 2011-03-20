package HoN::Client::Chat::Packet::JoinChannel;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';


=head1 NAME

HoN::Client::Chat::Packet::JoinChannel - JoinChannel packet.

=head1 VERSION

See HoN::Client

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, none added.

=cut

class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'JoinChannel' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ join_channel_request join_channel_response /]} );
class_has 'encode_id'   => ( is => 'ro', isa => 'Int', default => 0x1e00 );

class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x0400 );

has 'event_name'  => ( is => 'rw', isa => 'Str'  );


has 'channel'     => ( is => 'rw', isa => 'Str'  );
has 'channel_id'  => ( is => 'rw', isa => 'Int'  );
has 'topic'       => ( is => 'rw', isa => 'Str'  );

has 'op_count'   => ( is => 'rw', isa => 'Int'  );
has 'user_count' => ( is => 'rw', isa => 'Int'  );

has 'ops'   => ( is => 'rw', isa => 'ArrayRef'  );
has 'users' => ( is => 'rw', isa => 'ArrayRef'  );

# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
# response
#    ID: 0x0400
#    STRING: channel 
#    DWORD: channel id 
#    BYTE: unknown (channel flags? 0x18) 
#    STRING: topic 
#    DWORD: op count
#
#        DWORD: account id 
#        BYTE: type 
#
#    DWORD: user count
#
#        STRING: name 
#        DWORD: account id 
#        BYTE: state 
#        BYTE: flags 


    
     # parse struct
    $c->parse(<<'CCODE');
    
struct JoinChannel {
    u_16 id;
    char channel[];
};

    
struct JoinChannelResponse {
    String channel;
    account_id channel_id;
    byte unknown;
    String topic;
    dword op_count;
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
    $self->packed( $self->pack($self->name, $data) );
    
    # event
    $self->event_name('join_channel_request');
}



sub _decode_packet {
    my ($self) = @_;    
    
    # raw bits
    my $data = $self->decode_data;
    
    # unpack 
    my $unpacked = $self->manual_unpack($data);
    
    #use Data::Dumper;
    #print STDERR Dumper($unpacked);
    
    # populate attributes
    $self->$_($unpacked->{$_}) for keys %$unpacked;
        
    # evt name
    $self->event_name('join_channel_response');

}

sub manual_unpack {
    my ($self, $data) = @_;
    
#    ID: 0x0400
#    STRING: channel 
#    DWORD: channel id  
#    BYTE: unknown (channel flags? 0x18) 
#    STRING: topic 
#    DWORD: op count
#
#        DWORD: account id 
#        BYTE: type 
#
#    DWORD: user count
#
#        String user;
#        dword account_id;
#        byte state;
#        byte flags;
#        String symbol;
#        String color;
#        String icon;
#        
    my %unpacked;
    
    # STRING: channel
    $unpacked{channel} = unpack('Z*', $data);
    $data = substr $data, length( $unpacked{channel} ) + 1; 
  
    # DWORD: channel id 
    $unpacked{channel_id} = unpack('I<', $data); 
    $data = substr $data, 4;  # dword = 4 bytes
    
    # eat a byte
    # BYTE: unknown
    $data = substr $data, 1;
        
    # STRING: topic 
    $unpacked{topic} = unpack('Z*', $data);
    $data = substr $data, length( $unpacked{topic} ) + 1; 
    
    # DWORD: op countI
    $unpacked{op_count} = unpack('I<', $data); 
    $data = substr $data, 4;  
    
    # Decode ops if op_count > 1
    #        DWORD: account id 
    #        BYTE: type 
    for (my $i = 0; $i < $unpacked{op_count}; $i++) {
        my %op;
        $op{account_id} = unpack('I<', $data); 
        $data = substr $data, 4;  
        
        $op{type} = unpack('C', $data);
        $data = substr $data, 1;  
        
        push @{$unpacked{ops} }, \%op;
    }
    
    # DWORD: user count
    $unpacked{user_count} = unpack('I<', $data); 
    $data = substr $data, 4;  

    $self->_dump($data);
    
#        String user;
#        dword account_id;
#        byte state;
#        byte flags;
#        String symbol;
#        String color;
#        String icon;
    for (my $i = 0; $i < $unpacked{user_count}; $i++) {
        my %user;
        
        $user{nickname} = unpack('Z*', $data);
        $data = substr $data, length( $user{nickname} ) + 1;         

        $user{account_id} = unpack('I<', $data); 
        $data = substr $data, 4;
        
        $user{state} = $self->_decode_user_state( unpack('C', $data) ); 
        $data = substr $data, 1;
        
        
        $user{flags} = $self->_decode_user_flags( unpack('C', $data) ); 
        $data = substr $data, 1;

#        @user{qw/symbol color icon/} = unpack('Z*Z*Z*', $data);        
#        $data = substr $data, (length $user{symbol} + length $user{color} + length $user{icon}) + 3;

        $user{symbol} = unpack('Z*', $data);
        $data = substr $data, length( $user{symbol} ) + 1; 
        
        $user{color} = unpack('Z*', $data);
        $data = substr $data, length( $user{color} ) + 1; 
        
        $user{icon} = unpack('Z*', $data);
        $data = substr $data, length( $user{icon} ) + 1; 

        push @{$unpacked{users}}, \%user;
    }
    
    
    # data left
    $self->_dump($data);
  
    # return
    return \%unpacked;  
}

1;










