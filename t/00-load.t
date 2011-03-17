#!perl 
use Test::More tests => 2;

BEGIN {
    use_ok( 'HoN::Client' ) || print "Bail out!";
}

diag( "Testing HoN::Client $HoN::Client::VERSION, Perl $], $^X" );

# create instance
isa_ok(HoN::Client->new, 'HoN::Client', 'created instance');
