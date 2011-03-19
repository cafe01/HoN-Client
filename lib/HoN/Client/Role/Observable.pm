package HoN::Client::Role::Observable;

use Moose::Role;
use Carp qw/croak confess/;
use namespace::autoclean;

has '_events' => (is => 'rw', isa => 'HashRef', default => sub{{}} );
has '_listeners' => (is => 'rw', isa => 'HashRef', default => sub{{}} );



# add_events
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

# remove_events
sub remove_events {
    my ($self, @evt_name) = @_;
    
    for (@evt_name) {
        delete $self->_events->{$_};
        delete $self->_listeners->{$_};
    }
      
    return scalar @evt_name; 
}

# get_events
sub get_events {
    my ($self) = @_;
    return keys %{$self->_events};
}


# add_listener
sub add_listener {
    my ($self, $evt_name, $cb) = @_;        
    my $listeners = $self->get_listeners($evt_name);
    
    confess "I need a callback as 2nd parameter to add_listener." if (!$cb || ref $cb ne 'CODE');    
    push @$listeners, $cb;
    
    return 1;
}


# get_listeners
sub get_listeners {
    my ($self, $evt_name) = @_;
    confess "Pass a evt_name please!" unless $evt_name;
    confess "Event $evt_name doesn't exist! You can't add/remove listeners to it. " unless exists $self->_listeners->{$evt_name};
    my $listeners = $self->_listeners->{$evt_name} ||= [];
    return $listeners;
}


# remove_listener
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



# fire_event
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