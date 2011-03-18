#!perl 
use strict;
use warnings;
use HoN::Client;
use Test::More;        
use Test::Exception;        

# read hon credentials
my $cred_file = '_hon_credential';
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
my $c = new HoN::Client;

# chat before connecting (dies)
dies_ok { $c->chat } " chat before connecting (dies)";

# now connect
$c->connect($credential->{username}, $credential->{password});

# create chat
my $chat = $c->chat;
isa_ok($chat, 'HoN::Client::Chat', 'thing returned by chat()');

# chat has referencet o client
isa_ok($chat->client, 'HoN::Client::Client', 'thing returned by $chat->client()');

# connect
$chat->connect();








