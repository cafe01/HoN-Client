package HoN::Client::Role::Logger;

use Moose::Role;
use Log::Handler;

=head1 NAME

HoN::Client::Role::Logger - Shared logger for HoN::Client modules.

=head1 VERSION

See HoN::Client

=head1 ATTRIBUTES

=cut

has 'log'   => ( is => 'rw', builder => '_build_log' );
has '_log_name' => ( is => 'ro', isa => 'Str', default => 'hon_client_log');


sub _build_log {
    my $self = shift;
        
    # get existing log
    return Log::Handler->get_logger($self->_log_name) if Log::Handler->exists_logger($self->_log_name);
    
    # create new 
    my $log = Log::Handler->create_logger($self->_log_name);
    
    # add
    $log->add(
        screen => {
            log_to   => "STDOUT",
            maxlevel => "debug",
            minlevel => "emergency",
            message_layout => "%T [%L] %m",
        },
    );
    
        
    # return
    return $log;    
}

#
#sub BUILD {
#    my $self = shift;
#    
#}

1;