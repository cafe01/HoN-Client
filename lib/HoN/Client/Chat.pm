package HoN::Client::Chat;

use Moose;
use namespace::autoclean;
use HoN::Client::Chat::PacketFactory;
use Data::Hexdumper qw(hexdump);
use AnyEvent;   
use AnyEvent::Handle;

with 'HoN::Client::Role::Logger';
with 'HoN::Client::Role::Observable';

# TODO: Renomear Chat para Protocol ??

=head1 NAME

HoN::Client::Chat - HoN Chat client.

=head1 VERSION

Version 0.01

=head1 SYNOPSIS



=head1 ATTRIBUTES

=cut

has 'client'      => ( is => 'ro', isa => 'HoN::Client', required => 1 );
has 'server_port' => ( is => 'ro', isa => 'Int', default  => 11031 );

has 'is_connected' => ( is => 'rw', isa => 'Bool', default  => 0 );

has 'packet_factory' => (
    is      => 'ro',
    isa     => 'HoN::Client::Chat::PacketFactory',
    default => sub { HoN::Client::Chat::PacketFactory->new },
    handles => ['packets', 'decode_packet', 'encode_packet', '_has_encoder']
);

has 'handler'      => ( is => 'rw', isa => 'AnyEvent::Handle' );


=head1 METHODS

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    
    # register my events
    $self->add_events(qw/ packet_received disconnect connect /);
    
    # register packet events
    my @packet_events = map { @{ $_->events } } $self->packets;
    $self->add_events( @packet_events );
    
    # listen for 'login_success'
    $self->add_listener('login_success', sub { $self->_on_login_success(@_) });
}



=head2 connect

=cut

sub connect {
    my ($self) = @_;
         

    # start connection
    my $h; $h = new AnyEvent::Handle 
        connect  => [ $self->client->_chat_server => $self->server_port ],
        on_connect => sub {            
            $self->_on_connect(@_);         
            $self->fire_event('connect', $self, @_);   
        },
        on_error => sub {
            my ($hdl, $fatal, $msg) = @_;
            $self->log->debug("[Chat] Called: on_error:(fatal: $fatal) $msg");
            $self->fire_event('disconnect', $self, @_);
            $h->destroy;    # explicitly destroy handle
        },
        on_eof => sub {
            my ($hdl, $fatal, $msg) = @_;
            $self->log->debug("[Chat] Called: on_eof:(fatal: $fatal) $msg") if $self->client->verbose;
            $self->fire_event('disconnect', $self, @_);
            $h->destroy;    # explicitly destroy handle
        };
        
    # save handler
    $self->handler($h);
}


sub _on_connect {
    my ($self) = @_;
    
    # start hanlding packets:
    $self->handler->on_read(sub {
        my $h = shift;

        # some data is here, now queue the length-header-read (2 octets)
        $h->unshift_read (chunk => 2, sub {
            
            # header arrived, decode
            my $len = unpack "S>", $_[1];
                            
            # read ID
            shift->unshift_read (chunk => 2, sub {
                
                # subtract chunk from $len
                $len -= 2;
                
                # id arrived, decode
                my $id = unpack "S>", $_[1];
                
                # now read the payload
                shift->unshift_read (chunk => $len, sub {
                    my $buf = $_[1];                
                       
                    # decode packet
                    my $pkt = $self->decode_packet($id, $buf);
                    
                    # debug                
                    if (my $v = $self->client->verbose > 0) {
                        print STDERR "\n";    
                        $self->log->debug(sprintf("Packet ID: 0x%04x (%d bytes - len / %d bytes - buffer):\n", $id, $len, length $buf));
                        $pkt->_dump if $v >= 2;
                    }
                    
                    # fire named event
                    $self->fire_event($pkt->event_name, $self, $pkt);
                    
                    # fire generic event
                    $self->fire_event('packet_received', $self, $pkt);
                                         
                });
            });
        });
   });
   
    # log in
    $self->login;
}


sub _on_login_success {
    my ($self, $me_again, $pkt) = @_;
        
    # set connected
    $self->is_connected(1);
    
    # connect to saved chatrooms
    $self->join($_) foreach values %{ $self->client->_auth_data->{chatrooms} };
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
    
    # log
    $self->log->info("Sending packet:", $req_name);
    $self->log->debug(hexdump(data => $pkt->packed ));
    
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



=head2 login

Send a Login request.

=cut

sub login {
    my ($self) = @_;
    
    # log in
    $self->send_request('Login', {
        account_id => $self->client->user->account_id,
        cookie     => $self->client->_cookie,
    });
}




  1;
