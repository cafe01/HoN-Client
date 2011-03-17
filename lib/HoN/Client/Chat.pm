package HoN::Client::Chat;

use Moose;
use namespace::autoclean;
use Data::Hexdumper qw(hexdump);
use Convert::Binary::C;

with 'HoN::Client::Role::Logger';

=head1 NAME

HoN::Client::Chat - HoN Chat client.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS



=head1 ATTRIBUTES

=cut

# addr: 174.36.178.66:11031

has 'client'      => ( is => 'ro', isa => 'HoN::Client', required => 1 );
has 'server_port' => ( is => 'ro', isa => 'Int',         default  => 11031 );

#has 'packet_factory' => ( is => 'ro', isa => 'HoN::Client::Chat::PacketFactory' );




=head1 METHODS

=head2 connect

=cut

sub {
    my ($self) = @_;

    my $c = Convert::Binary::C->new( ByteOrder => 'BigEndian' );

    $c->parse_file('structs.c');

    my $data = {
        id         => 0,
        unknown    => 0x0c,
        account_id => 1462544,
        cookie     => [],
    };

    my $binary = $c->pack( 'Packet', $data );

    print hexdump( data => $binary );

    return;

    # store results here
    my ( $response, $header, $body );

    # start connection
    my $handle; $handle = new AnyEvent::Handle
      connect  => [ $self->client->_chat_server => $self->server_port ],
      on_error => sub {
        $handle->destroy;    # explicitly destroy handle
      },
      on_eof => sub {
        #$cb->($response, $header, $body);
        $handle->destroy;    # explicitly destroy handle
      };

    # create Login packet
#    my $login_pkt = $self->new_packet('Login', {
#        id         => 0,
#        unknown    => 0x0c,
#        account_id => 1462544,
#        cookie     => to_char_dec_array('f840a975237b4ae10862d0bbb11f2d90'),
#    });

    #  $handle->push_write($login_pkt);
    
    #  # now fetch response status line
    #  $handle->push_read (line => sub {
    #     my ($handle, $line) = @_;
    #     $response = $line;
    #  });
    #
    #  # then the headers
    #  $handle->push_read (line => "\015\012\015\012", sub {
    #     my ($handle, $line) = @_;
    #     $header = $line;
    #  });
    #
    #  # and finally handle any remaining data as body
    #  $handle->on_read (sub {
    #     $body .= $_[0]->rbuf;
    #     $_[0]->rbuf = "";
    #  });

  }

  1;
