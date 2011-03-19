package HoN::Client::Role::Observable;

use Moose::Role;
use Carp qw/croak confess/;
use namespace::autoclean;

=head1 NAME

HoN::Client::Role::Observable - Role providing oservable-like methods.

=head1 VERSION

See HoN::Client

=head1 SYNOPSIS

A class consuming this role becomes observable.

1. use add_events to declare event names that can be fired by this class.
2. use add_listener  to bind a callback to a event.
3. then use fire_event  to run all callbacks added via add_listener, in the order they were added.

=head1 ATTRIBUTES

No public attributes.

And the only two private attributes are:

 - _events
 - _listeners
 
you should not use them directly tho.

=cut

has '_events' => (is => 'rw', isa => 'HashRef', default => sub{{}} );
has '_listeners' => (is => 'rw', isa => 'HashRef', default => sub{{}} );

=head1 METHODS

=head2 add_events

=over 4

=item Arguments: @event_names

=item Return Value: $number_of_added_events

=back

    printf "Added %d events.", $observable->add_events(qw/ foo bar baz /); # Added 3 events.

=cut

sub add_events {
    my ($self, @evt_name) = @_;        
    
    for( @evt_name) {        
        # register event name   
        $self->_events->{$_} = 1;
        
        # create listeners arrray (care taken not to override array in case event is added twice+)
        $self->_listeners->{$_} ||= [];
    }
    
    return scalar @evt_name; 
}


=head2 remove_events

=over 4

=item Arguments: @event_names

=item Return Value: $number_of_added_events

=back

    printf "Removed %d events.", $observable->add_events(qw/ foo bar baz /); # Removed 3 events.
    
Does not check if event exists, just deletes the names from _events and _listeners.

The observable will not be able to fire the removed events, and the list of listeners will be forgotten.

=cut

sub remove_events {
    my ($self, @evt_name) = @_;
    
    for (@evt_name) {
        delete $self->_events->{$_};
        delete $self->_listeners->{$_};
    }
      
    return scalar @evt_name; 
}





=head2 get_events

=over 4

=item Arguments: none.

=item Return Value: @event_names

=back

    my @events = $observable->get_events;
    printf "This observable can fire %s events:\n", scalar @events;
    print "$_\n" foreach (@events)
    
Return a list of events this observable can fire. See L</add_events>.

=cut

sub get_events {
    my ($self) = @_;
    return keys %{$self->_events};
}


=head2 add_listener

=over 4

=item Arguments: $evt_name, $cb

=item Return Value: 1 for success. Dies on errors (via confess).

=back

    $observable->add_listener('whisper_received', sub {
        my ($chat, $pkt) = @_;
        printf "(Whisper from %s): %s\n", $pkt->user, $pkt->message;
    });
    
Bind a callback to a event.

=cut

sub add_listener {
    my ($self, $evt_name, $cb) = @_;        
    my $listeners = $self->get_listeners($evt_name);
    
    confess "I need a callback as 2nd parameter to add_listener." if (!$cb || ref $cb ne 'CODE');    
    push @$listeners, $cb;
    
    return 1;
}

=head2 get_listeners

=over 4

=item Arguments: $event_name

=item Return Value: $listeners (ArrayRef)

=back

Returns a arrayref pointing to a list of callbacks listening to the event $event_name. Dies on errors.

=cut

sub get_listeners {
    my ($self, $evt_name) = @_;
    confess "Pass a evt_name please!" unless $evt_name;
    confess "Event $evt_name doesn't exist! You can't add/remove listeners to it. " unless exists $self->_listeners->{$evt_name};
    my $listeners = $self->_listeners->{$evt_name} ||= [];
    return $listeners;
}


=head2 remove_listener

=over 4

=item Arguments: $evt_name [, $cb]

=item Return Value: none.

=back

If coderef $cb is passed, remove it from the listerners of $event_name event, 
if no callback passed, removes all listeners of  $event_name event.

=cut

sub remove_listener {
    my ($self, $evt_name, $cb) = @_;
    
    confess "Pass at least the event name" unless $evt_name;
    
    # delete only $cd from $evt_name listeners
    if ($cb) {
        my @new_listeners = grep {$_ != $cb } @{$self->_listeners->{$_}};
        return $self->_listeners(\@new_listeners);
    }
    
    # delete all listeners from named event
    $self->_listeners->{$evt_name} = [];
}


=head2 fire_event

=over 4

=item Arguments:  $evt_name [, @cb_args]

=item Return Value: whatever the last callback executed returns

=back

Calls all listeners of event $evt_name, passing @cb_args as arguments.

=cut

sub fire_event {
    my ($self, $evt_name, @cb_args) = @_;
        
    my $listeners = $self->get_listeners($evt_name);
        
    my $last_return;
    foreach my $cb (@$listeners) {
        $last_return = $cb->(@cb_args);
    }
    
    $last_return;
}









1;