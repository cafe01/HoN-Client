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

# testing HoN::Client::User
diag('testing HoN::Client::User');

# create client and connect
my $c = new HoN::Client;
my $user = $c->connect($credential->{username}, $credential->{password});

# nickname / id
is($user->nickname, $credential->{nickname}, 'right nickname');
like($user->account_id, qr/^\d+$/, 'has some account_id');

# coins
like($user->gold_coins, qr/^\d+$/,  'gold_coins() return a number');
like($user->silver_coins, qr/^\d+$/, 'silver_coins() return a number');









