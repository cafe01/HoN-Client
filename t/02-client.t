#!perl 
use strict;
use warnings;
use FindBin;
use HoN::Client;
use Test::More;

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

# testing HoN::Client->connect()
diag('testing HoN::Client');

# create client
my $c = new HoN::Client();

# connect
my $cv1 = $c->connect('foo', 'bar', sub {
   my ($client, $success, $msg) = @_;
   
    # bad username/password
   is($success, 0, 'bad username/password'); 
   $c->unloop;
});

isa_ok($cv1, 'AnyEvent::CondVar', 'return value of connect()');

# enter loop
$c->loop;


# right username/password
$c->connect($credential->{username}, $credential->{password}, sub {
   my ($client, $success, $msg) = @_;
   
    # right username/password
   is($success, 1, 'right username/password');   
   $c->unloop;
});

$c->loop;

# user()
isa_ok($c->user, 'HoN::Client::User', 'thing returned by $client->user()');

# cookie
like($c->_cookie, qr/^[0-9a-f]{32}$/, 'has md5-like cookie');

# chat server
like($c->_chat_server, qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, 'has chat server IP (chat_url)');







