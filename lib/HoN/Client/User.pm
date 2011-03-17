package HoN::Client::User;

use Moose;

with 'HoN::Client::Role::Logger';


=head1 NAME

HoN::Client::User - Represents a logged in user.

=head1 VERSION

See HoN::Client.

=cut


has 'config'     => ( is => 'ro', isa => 'HashRef', required => 1 );

has 'nickname'   => ( is => 'rw', isa => 'Str', lazy_build => 1 );
has 'account_id' => ( is => 'rw', isa => 'Int', lazy_build => 1 );
has 'gold_coins' => ( is => 'rw', isa => 'Int', lazy_build => 1 );
has 'silver_coins' => ( is => 'rw', isa => 'Int', lazy_build => 1 );


sub _build_nickname {
    my ($self) = @_;    
    return $self->config->{nickname};
}

sub _build_account_id {
    my ($self) = @_;    
    return $self->config->{account_id};
}

sub _build_gold_coins {
    my ($self) = @_;    
    return $self->config->{points};
}

sub _build_silver_coins {
    my ($self) = @_;    
    return $self->config->{mmpoints};
}




1;