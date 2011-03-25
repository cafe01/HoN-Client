#!perl 
use strict;
use warnings;
use FindBin;
use HoN::Client;
use Test::More;        
use Test::Exception;        

# read hon credentials
my $cred_file = $FindBin::Bin.'/_hon_credential';
plan( skip_all => "Could not find hon credentials ($cred_file)." ) unless -e $cred_file;

# plan
plan('no_plan');

# read cred file
my ($credential, $VAR1);
open(R, '<', $cred_file) || die $!;
eval join '', (<R>);    
$credential = $VAR1;

# testing HoN::Client::Chat
diag('testing HoN::Client::Chat');

# create client
my $c = new HoN::Client(verbose => 0);


# now connect
$c->connect( $credential->{username}, $credential->{password}, sub { $c->unloop } );
$c->loop;

# create chat
my $chat = $c->chat;
isa_ok($chat, 'HoN::Client::Chat', 'return value of chat()');

# chat has referencet o client
isa_ok($chat->client, 'HoN::Client', 'return value of $chat->client()');


# live test
$c->connect( $credential->{username}, $credential->{password}, sub {
    
    $chat->add_listener('login_success', sub{
        ok(1, 'fired login_success');
        $c->unloop;
    });

    # connect
    $chat->connect();    
    
});


$c->loop;








