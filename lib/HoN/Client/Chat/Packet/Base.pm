package  HoN::Client::Chat::Packet::Base;

use Moose;    
use MooseX::ClassAttribute;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;
use Data::Dumper;

=head1 NAME

HoN::Client::Chat::Packet::Base - Base class  for HoN Chat client packets.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

Extend this class to implement chat packets.

=head1 CLASS ATTRIBUTES

=cut


class_has 'name'            => ( is => 'ro', isa => 'Str', default => '' );
class_has 'event_name'      => ( is => 'rw', isa => 'Str', default => '' ); 

class_has 'events'          => ( is => 'ro', isa => 'ArrayRef', default => sub{ [] } ); # all possible events related to this packet 

class_has 'decode_id'       => ( is => 'ro', isa => 'Int', default => '' );
class_has 'encode_id'       => ( is => 'ro', isa => 'Int', default => '' );



=head1 CLASS ATTRIBUTES

=cut
has 'id'        => ( is => 'rw', isa => 'Int' );

has 'packed'     => ( is => 'rw' );
has 'unpacked' => ( is => 'rw', isa => 'HashRef' );

has 'decode_data'    => ( is => 'ro', predicate => 'has_decode_data' );
has 'encode_data'    => ( is => 'ro', isa => 'HashRef', predicate => 'has_encode_data' );

has 'binary_c'  => (
    is      => 'ro',
    isa     => 'Convert::Binary::C',
    lazy_build => 1,
    handles => {
         'pack'     => 'pack' ,
         'unpack'   => 'unpack' ,
         'parse_c'  => 'parse',
    }
);



sub _build_binary_c {
    my ($self) = @_;
    
    my $c =  Convert::Binary::C->new( ByteOrder => 'BigEndian' );
    
    # parse c code
    $c->parse(<<'CCODE');
    
typedef char byte;
typedef unsigned short u_16;
typedef unsigned int u_32;
typedef u_32 dword;
typedef char String[];
typedef u_32 account_id;
typedef char cookie[32];
typedef char ConcatString[];

CCODE

    # tags
    $c->tag('cookie', Format => 'String');
    $c->tag('String', Format => 'String');
    $c->tag('account_id', ByteOrder => 'LittleEndian');
    $c->tag('dword', ByteOrder => 'LittleEndian');
    
    my $extracted_strings = 0;
    my $packed_buf = '';
    $c->tag('ConcatString', Format => 'Binary', Hooks => { 
        unpack => sub {
            my $data = shift;
                    
            # unpack
            my @fields = unpack('Z*' x ++$extracted_strings , $data);
            my $field = pop @fields;
            
            return $field;
        },
        
        pack => sub {
            my $packed = pack('Z*', $_[0]);
            #print STDERR "Packing ($_[0]):\n", hexdump(data=> $_[0]), "into:\n", hexdump(data=> $packed);
            $packed_buf .= $packed;
            
            #print STDERR "Packing ($_[0]):\n", hexdump(data=> $_[0]), "into:\n", hexdump(data=> $packed), "Buf:\n",  hexdump(data=> $packed_buf);
            $packed_buf;
        }
    });

    return $c;
}




=head1 METHODS

=head2 BUILD

Encode/decode packet data.

=cut
sub BUILD {
    my $self = shift;
        
    # load c code
    
    
    # crap shit?
    die "You can only encode_data or decode_data, not both!" if $self->has_encode_data && $self->has_decode_data;
    
    # encode / decode
    $self->_encode_packet if $self->has_encode_data;
    $self->_decode_packet if $self->has_decode_data;
}




sub _dump {
    my ($self, $data) = @_;    
    my $some_data = $data || $self->packed || $self->decode_data;
    print STDERR hexdump(data => $some_data) if $some_data;
}



sub _unpack {
    my ($self, $data, $unpacked, $pos, @profile) = @_;
    
    # TODO: could turn @profile into a Hash::MultiValue object.

    # types
    my $types = {
        string => {
            tpl => 'Z*',
            sizeof => sub { length(shift) + 1 }
        },
        byte => {
            tpl => 'C',
            sizeof => sub { 1 }
        },
        u_16 => {
            tpl => 'S',
            sizeof => sub { 2 }
        },
        dword => {
            tpl => 'I<',
            sizeof => sub { 4 }
        }
        
    };  
    
    # unpack acording to profile
    #my $data_len = length(unpack 'H*', $$data) / 2;
    my $data_len = length($$data);
    
    #$self->_dump($$data);
    
    while (@profile && $pos < $data_len) {
        
        #printf STDERR "Data_len: %d, pos: %d\n", $data_len, $pos;
        
        my $field_type    = shift @profile;
        my $field_name  = shift @profile;
        
#        use Data::Dumper;
#        print STDERR "$field_name => $field_type\n";
        
        # get type handler
        my $type = $types->{ $field_type };
        
        # unpack and increment $pos
        $unpacked->{$field_name} = unpack($type->{tpl}, substr $$data, $pos);  
        $pos += $type->{sizeof}->($unpacked->{$field_name});
    }
    
    
    return $pos;
}




sub _decode_user_state {
    my ($self, $state) = @_;
    
    my $decoded = {};
    
#    Offline: 0x00 
#    Online: 0x03 
#    In Lobby: 0x04 
#    In Game: 0x05 
    my %state_mask = (
        online   => 0x03,
        in_lobby => 0x04, 
        in_game  => 0x05,
    );
    
    for (keys %state_mask) {
        $decoded->{$_} = (($state & $state_mask{$_}) == $state_mask{$_}) ? 1 : 0;
    }
        
    return $decoded;
}



sub _decode_user_flags {
    my ($self, $state) = @_;
    
    my $decoded = {};
    
    #    None: 0x00 
    #    Moderator: 0x01 
    #    Founder: 0x02 
    #    Prepurchased:0x40 
    my %mask = (
        is_moderator    => 0x01, 
        is_founder      => 0x02,
        is_prepurchased => 0x40 
    );
    
    for (keys %mask) {
        $decoded->{$_} = (($state & $mask{$_}) == $mask{$_}) ? 1 : 0;
    }
        
    return $decoded;
}





__PACKAGE__->meta()->make_immutable();

1;

















