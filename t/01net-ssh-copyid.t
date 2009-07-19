# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Net-ParSCP.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use warnings;
use strict;
use Test::More tests => 2;
BEGIN { use_ok('Net::SSH::CopyId') };

#########################

SKIP: {
  skip("Developer test", 1) unless ($ENV{DEVELOPER} && -x "script/pssh-copy-id" && ($^O =~ /nux$/));

     my $output = `script/pssh-copy-id -P -i ~/.ssh/id_dsa 127.0.0.1 2>&1`;
     my $ok = $output =~ m{Sending key /home/.+/.ssh/id_dsa.pub to 127.0.0.1 as .+}s;
     ok($ok, 'Very simple smoke test');

}



