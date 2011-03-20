package HoN::Client::Chat::Packet::UserUpdate;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';



=head1 NAME

HoN::Client::Chat::Packet::UserUpdate - UserUpdate packet.

=head1 VERSION

See HoN::Client

=head1 SYNOPSIS

=head1 ATTRIBUTES

All of base class, plus:

   - account_id
    - state
        - online
        - in_lobby
        - in_game
    - flags
        - is_moderator
        - is_founder
        - is_prepurchased
    - clan
    - symbol
    - color
    - icon


=cut

class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'UserUpdate' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ user_update /]} );
class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x0c00 );

has 'event_name'  => ( is => 'rw', isa => 'Str', default => 'user_update' );

has 'account_id'   => ( is => 'rw', isa => 'Int', default => 0 );
has 'state'   => ( is => 'rw', isa => 'Int' );
has 'flags'   => ( is => 'rw', isa => 'Int' );

has 'online'    => ( is => 'rw', isa => 'Bool', default => 0);
has 'in_game'   => ( is => 'rw', isa => 'Bool', default => 0);
has 'in_lobby'  => ( is => 'rw', isa => 'Bool', default => 0);

has 'is_moderator'    => ( is => 'rw', isa => 'Bool', default => 0);
has 'is_founder'      => ( is => 'rw', isa => 'Bool', default => 0);
has 'is_prepurchased' => ( is => 'rw', isa => 'Bool', default => 0);



has 'clan'   => ( is => 'rw', isa => 'Str' );
has 'clan_id'   => ( is => 'rw', isa => 'Int' );
has 'symbol' => ( is => 'rw', isa => 'Str' );
has 'color'  => ( is => 'rw', isa => 'Str' );
has 'icon'   => ( is => 'rw', isa => 'Str');


# add C code
around '_build_binary_c' => sub {
    my $orig = shift;
    my $self = shift;
    
    my $c = $self->$orig(@_);
    
     # parse struct
#    ID: 0x0C 
#    DWORD: account id 
#    BYTE: state 
#    BYTE: flags 
#    DWORD: clan id 
#    STRING: clan 
#    STRING: server (if in lobby/in game) 
#    STRING: game name (if in game)#
#        DWORD: match id 

#    DWORD: account id 
#    BYTE: state 
#    BYTE: flags 
#    DWORD: clan id 
#    STRING: clan 
#    STRING: symbol (bandeira do brasil) 
#    STRING: color 
#    STRING: icon 

# String: server address
# String: game name
# 6 bytes
# String: Piaba (??????????)
# String: region (USE)
# String: mode (normal)
# String: map (caldavar)

    $c->parse(<<'CCODE');
    
    
struct UserUpdate {
    account_id account_id;
    byte state;
    byte flags;
    account_id clan_id;
    ConcatString clan;
    ConcatString symbol;
    ConcatString color;
    ConcatString icon;
};

CCODE

    # return
    return $c;
};



sub _decode_packet {
    my ($self) = @_;    
    
    # raw bits
    my $data = $self->decode_data;

    #    DWORD: account id 
    #    BYTE: state 
    #    BYTE: flags 
    #    DWORD: clan id 
    #    STRING: clan 
    #    STRING: symbol (bandeira do brasil) 
    #    STRING: color 
    #    STRING: icon 
    
    # String: server address
    # String: game name
    # 6 bytes
    # String: Piaba (??????????)
    # String: region (USE)
    # String: mode (normal)
    # String: map (caldavar)
    
    my $unpacked = {};
    $self->_unpack(\$data, $unpacked, 0,
        'dword'     => 'account_id',
        'byte'        => 'state',
        'byte'        => 'flags',
        'dword'     => 'clan_id',
        'string'      => 'clan',
        'string'      => 'symbol',
        'string'      => 'color',
        'string'      => 'icon',  
        'string'      => 'server_addr',
        'string'      => 'game_name',
        'dword'     => 'unknown1',
        'u_16'       => 'unknown2',
        'string'      => 'unknown_string',
        'string' => 'region',
        'string' => 'mode',
        'byte' => 'unknown_byte',
        'string' => 'map',
    );
    
    use Data::Dumper;
    print STDERR Dumper($unpacked);
    
    
    # unpack    
    #my $unpacked = $self->unpack($self->name, $data);
    
    # populate attributes
    $self->$_($unpacked->{$_}) for qw/ account_id state flags clan symbol color icon/;
    
    # decode state
    my $decoded_state = $self->_decode_user_state($unpacked->{state});
    $self->$_( $decoded_state->{$_} ) for keys %$decoded_state;
    
    # decode flags
    my $flags = $unpacked->{flags};
    my $decoded_flags = $self->_decode_user_flags( $unpacked->{flags} );
    $self->$_( $decoded_flags->{$_} ) for keys %$decoded_flags;
}


















1;