#!perl 
use strict;
use warnings;
use HoN::Client;
use Test::More;

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

# testing HoN::Client->connect()
diag('testing HoN::Client->connect()');

# create client
my $c = new HoN::Client;

# bad username/password
is($c->connect('foo', 'bar'), 0, 'bad username/password');

# right username/password
my $user = $c->connect($credential->{username}, $credential->{password});
isa_ok($user, 'HoN::Client::User', ''thing returned by  connect()');
isa_ok($c->user, 'HoN::Client::User', 'thing returned by $client->user()');


# cookie
like($c->_cookie, qr/^\w{32}$/, 'has md5-like cookie');

# chat server
like($c->_chat_server, qr/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/, 'has chat server IP (chat_url)');







