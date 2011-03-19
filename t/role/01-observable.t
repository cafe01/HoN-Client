#!perl 
use strict;
use warnings;
use HoN::Client;
use Test::More;        
use Test::Exception;    
use FindBin;    

# read hon credentials
my $cred_file = $FindBin::Bin.'/../_hon_credential';
plan( skip_all => "Could not find hon credentials ($cred_file)." ) unless -e $cred_file;

# plan
plan('no_plan');

# read cred file
my ($credential, $VAR1);
open(R, '<', $cred_file) || die $!;
eval join '', (<R>);    
$credential = $VAR1;

# testing HoN::Client::Role::Observable
diag('testing HoN::Client::Role::Observable');

# create client n connect
my $c = new HoN::Client;
$c->connect($credential->{username}, $credential->{password});

# create chat
my $chat = $c->chat;

# empty listeners
$chat->remove_events($chat->get_events);

# add_events
is($chat->add_events(qw/ foo bar /), 2, 'add_events returns number of added events');

# get_events
is_deeply([$chat->get_events], [qw/ bar foo /], 'get_events returns correct list');

# remove_events
is($chat->remove_events('foo'), 1, 'remove_events returns number of added removed');

# get_events
is_deeply([$chat->get_events], [qw/ bar /], 'get_events has correct list');


# add listener - no args - dies
dies_ok { $chat->add_listener } 'add listener - dies - no args';

# add listener - unknown event - dies
dies_ok { $chat->add_listener('unknown_event') } 'add listener - dies - unknown event';

# add listener - no 2nd parameter (cb) - dies
dies_ok { $chat->add_listener('bar') } 'add listener - dies - no 2nd parameter (cb)';

# add listener - 2nd parameter is not a coderef - dies
dies_ok { $chat->add_listener('bar', 'not a code ref') } 'add listener - dies - 2nd parameter is not a coderef';

# fire_event - tested inside callbacks
my @cb_args = ('cb_arg1', 'cb_arg2', 'cb_arg3');

my $cb1 = sub {  
    is_deeply([ @_ ],  \@cb_args, "fire event - callback got all passed args");
};

my $cb2 = sub {  
    is_deeply([ @_ ], \@cb_args, "fire event - callback got all passed args - 2nd listener");
};

# add listener - all params ok
is($chat->add_listener('bar', $cb1),  1,  'add listener - all params ok');
is($chat->add_listener('bar', $cb2),  1,  'add listener - all params ok - 2nd listener');

# fire event
$chat->fire_event('bar', @cb_args);








