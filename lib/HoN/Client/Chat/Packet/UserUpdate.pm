package HoN::Client::Chat::Packet::UserUpdate;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';



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
has 'symbol' => ( is => 'rw', isa => 'Str' );
has 'color'  => ( is => 'rw', isa => 'Str' );
has 'icon'   => ( is => 'rw', isa => 'Str' );


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
    
    # unpack    
    my $unpacked = $self->unpack($self->name, $data);
    
    # populate attributes
    $self->$_($unpacked->{$_}) for (qw/ account_id state flags clan symbol color icon/);
    
    # decode state
    my $state = $unpacked->{state};
#    Offline: 0x00 
#    Online: 0x03 
#    In Lobby: 0x04 
#    In Game: 0x05 
    my %state_mask = (
        online   => 0x03,
        in_lobby => 0x04, 
        in_game  => 0x05,
    );
    
    for (qw/ online in_lobby in_game/) {
        $self->$_(1) if (($state & $state_mask{$_}) == $state_mask{$_});
    }
    
    
    # decode flags
    my $flags = $unpacked->{flags};
    #    None: 0x00 
    #    Moderator: 0x01 
    #    Founder: 0x02 
    #    Prepurchased:0x40 
    my %flag_mask = (
        moderator    => 0x01, 
        founder      => 0x02,
        prepurchased => 0x40 
    );
    
    for (keys %flag_mask) {
        my $attr = "is_$_";
        $self->$attr(1) if (($flags & $flag_mask{$_}) == $flag_mask{$_});
    }
}
















1;