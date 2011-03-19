package HoN::Client::Chat;

use Moose;
use namespace::autoclean;
use HoN::Client::Chat::PacketFactory;
use Data::Hexdumper qw(hexdump);
use AnyEvent;   
use AnyEvent::Handle;

with 'HoN::Client::Role::Logger';
with 'HoN::Client::Role::Observable';

=head1 NAME

HoN::Client::Chat - HoN Chat client.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS



=head1 ATTRIBUTES

=cut


has 'client'      => ( is => 'ro', isa => 'HoN::Client', required => 1 );
has 'server_port' => ( is => 'ro', isa => 'Int',         default  => 11031 );

has 'packet_factory' => (
    is      => 'ro',
    isa     => 'HoN::Client::Chat::PacketFactory',
    default => sub { HoN::Client::Chat::PacketFactory->new },
    handles => ['packets', 'decode_packet', 'encode_packet']
);

has 'handler'      => ( is => 'rw', isa => 'AnyEvent::Handle' );


=head1 METHODS

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    
    # register packet events
    my @packet_events = map { @{ $_->events } } $self->packets;
    $self->add_events( @packet_events );
}



=head2 connect

=cut

sub connect {
    my ($self) = @_;
    
    # 
    my $cv = AnyEvent->condvar;

    # start connection
    my $h; $h = new AnyEvent::Handle 
        connect  => [ $self->client->_chat_server => $self->server_port ],
        on_connect => sub {
            $self->_on_connect(@_);
        },
        on_error => sub {
            $self->log->debug('Called: on_error');
            $h->destroy;    # explicitly destroy handle
            $cv->send;
        },
        on_eof => sub {
            $self->log->debug('Called: on_eof');
            $h->destroy;    # explicitly destroy handle
            $cv->send;
        };
        
    # save handler
    $self->handler($h);
        
    # hold until connection is completed (or failed)
    $cv->recv;
    
}

sub _on_connect {
    my ($self) = @_;
    
    # start hanlding packets:
    $self->handler->on_read(sub {
        my $h = shift;

        # some data is here, now queue the length-header-read (4 octets)
        $h->unshift_read (chunk => 2, sub {
            
            # header arrived, decode
            my $len = unpack "S>", $_[1];
                
            printf STDERR "\n<==\nGot packet: %d bytes: ",$len;
            
            # read ID
            shift->unshift_read (chunk => 2, sub {
                
                # subtract chunk from $len
                $len -= 2;
                
                # id arrived, decode
                my $id = unpack "S>", $_[1];
                printf STDERR "Packet ID: 0x%04x\n",$id;
                
                # now read the payload
                shift->unshift_read (chunk => $len, sub {
                    my $buf = $_[1];                
    
                    printf STDERR "Data (%d bytes - len / %d bytes - buffer):\n", $len, length $buf;
                    print STDERR hexdump(data => $buf ) if $buf;
                    
                    # decode packet
                    my $pkt = $self->decode_packet($id, $buf);
                    
                    # fire event
                    $self->fire_event($pkt->event_name, $self, $pkt);                     
                });
            });
        });
   });
   
    # log in
    $self->send_request('Login', {
        account_id => $self->client->user->account_id,
        cookie     => $self->client->_cookie,
    });
}



=head2 send_request

Arguments: ($request_name, $packet_data)

Build packet of type $request_name, using $packet_data and sends to the write queue.

Reponses are handled at the main on_read callback. See _on_connect.

=cut
sub send_request {
    my ($self, $req_name, $req_data) = @_;
      
    # build pkt    
    my $pkt = $self->encode_packet($req_name, $req_data);
    
    print STDERR "\n=>\nSending packet:\n";
    print STDERR hexdump(data => $pkt->packed );
    
    # send
    $self->handler->push_write($pkt->packed);
    
    # fire event
    $self->fire_event($pkt->event_name, $self, $pkt);
}



=head2 join

Arguments: $channel_name

Joins a channel.

=cut

sub join {
    my ($self, $channel) = @_;
    
    $self->send_request('JoinChannel', { channel => $channel }); 
}






  1;
