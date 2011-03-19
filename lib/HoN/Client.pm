package HoN::Client;

use Data::Dumper;

use Moose;
use namespace::autoclean;
use Digest::MD5 qw(md5_hex);
use LWP::UserAgent;
use PHP::Serialization qw(unserialize);

use HoN::Client::User;
use HoN::Client::Chat;

with 'HoN::Client::Role::Logger';


=head1 NAME

HoN::Client - A client for the Heroes of Newerth master server and chat protocol. 

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

A perl clien for Heroes of Newerth

=head1 EXPORT

Pure OO module.

=head1 ATTRIBUTES

 - user

=cut

has 'user'    => ( is => 'rw', isa => 'HoN::Client::User' );
has 'chat'    => ( is => 'rw', isa => 'HoN::Client::Chat', lazy_build => 1 );


has 'is_connected'    => ( is => 'rw', isa => 'Bool', default => 0 );

has '_auth_data' => ( is => 'rw', isa => 'HashRef' );
has '_cookie' => ( is => 'rw', isa => 'Str' );
has '_chat_server' => ( is => 'rw', isa => 'Str' );


sub _build_chat {
    my $self = shift;
    
    # die unless connected
    die "You can't chat() before connect()" unless $self->is_connected;
    
    return HoN::Client::Chat->new(client => $self);
}


=head1 METHODS

=head2 new

Create a new client instance. 

Sets up log handler.

=head2 connect

Authenticates to master server, returns a HoN::Client::User object representing the user if successful, undef otherwise. 

=cut

sub connect {
    my ($self, $username, $password) = @_;
    
    die "Pass a username and password please!" unless ($username && $password);
        
    # build url
    my $url = 'http://masterserver.hon.s2games.com/client_requester.php?f=auth&login='.$username.'&password='. md5_hex($password);
    $self->log->debug("Auth url: $url");
    
    # do request
    $self->log->info('Authenticating to master server.');
    my $ua = LWP::UserAgent->new( agent => '' );
    my $res = $ua->get($url);
    
    # request error
    unless ($res->is_success) {
        die "Request error: ". $res->status_line;
    }
    
    # parse response
    my $auth_data = unserialize($res->content);
    $self->_auth_data( $auth_data );
    
    # failed authentication
    unless ($auth_data->{0}) {
        $self->log->error($auth_data->{auth});
        return 0;
    }
    
    # connected!
    $self->is_connected(1);
    
    # setup attributes
    $self->_cookie($auth_data->{cookie});
    $self->_chat_server($auth_data->{chat_url});
    
    # all good, create new User
    return $self->user(HoN::Client::User->new( config => $auth_data ));
}







































=head1 AUTHOR

"Cafe", C<< <"cafe at q1software.com"> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-hon-client at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=HoN-Client>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc HoN::Client


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=HoN-Client>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/HoN-Client>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/HoN-Client>

=item * Search CPAN

L<http://search.cpan.org/dist/HoN-Client/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2011 "Cafe".

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of HoN::Client
