package HoN::Client::Chat::Packet::UserUpdate;

use Moose;
use MooseX::ClassAttribute;
extends 'HoN::Client::Chat::Packet::Base';



class_has 'name'        => ( is => 'ro', isa => 'Str', default => 'UserUpdate' );
class_has 'events'  => ( is => 'ro', isa => 'ArrayRef', default => sub{[qw/ user_update /]} );
class_has 'decode_id'   => ( is => 'ro', isa => 'Int', default => 0x0c00 );

has 'event_name'  => ( is => 'rw', isa => 'Str', default => 'user_update' );

has 'clan'   => ( is => 'rw', isa => 'Str', default => '' );
has 'symbol' => ( is => 'rw', isa => 'Str', default => '' );
has 'color'  => ( is => 'rw', isa => 'Str', default => '' );
has 'icon'   => ( is => 'rw', isa => 'Str', default => '' );


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
    
typedef char ConcatString[];
    
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

    my $extracted_strings = 0;
    $c->tag('ConcatString', Format => 'Binary', Hooks => { unpack => sub {
        my $data = shift;
                
        # unpack
        my @fields = unpack('Z*' x ++$extracted_strings , $data);
        my $field = pop @fields;
        
        return $field;
    }});

    
    
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
    $self->$_($unpacked->{$_}) for (qw/ clan symbol color icon/);
}
















1;