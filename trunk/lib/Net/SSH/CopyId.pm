package Net::SSH::CopyId;

use 5.008008;
use strict;
use warnings;

require Exporter;

use Carp;

use Net::SSH::Expect;
use Pod::Usage;
use Net::HostLanguage;



our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Net::SSH::CopyId ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	write_remote_key
	get_users_from_config
	slurp
	usage
	$DEBUG
);

our $VERSION = '1.5';

our $DEBUG = 0;

# Write remote key subroutine
# 
# This subroutine makes the ssh connection to the remote host with the given user and password
# and, if the connection is sucessful, launch a shell script that check if the key existed before
# and, if not, writes the key in the correct file
#
sub write_remote_key {

		  my $key = shift ;
		  my $host = shift ;
		  my $user = shift;
		  my $pass = shift;

		  my $ssh = Net::SSH::Expect->new(
								host => $host,
								password => $pass,
								user => $user,
								raw_pty => 1,
								no_terminal => 1,
								);
		  warn "~~~ Trying to log you on $host as $user ... \n" if ($DEBUG);

# Maybe a key already exists
		  $ssh->login() or croak " SSH Process couldn't start : $!";
		  warn "~~~ Logged to: $host as $user \n" if ($DEBUG);
# Check if the key is already published
		  my $metakey = quotemeta($key);
# We're assuming that you have at least sh on the remote machine
		  my $command = <<"CHECK_KEY";
		  umask 077;
		  mkdir -p .ssh;
		  touch .ssh/authorized_keys;
		  grep -c "$metakey" .ssh/authorized_keys &> /dev/null;
		  if [ ! \$? ]; then
					 echo $metakey >> .ssh/authorized_keys;
		  else
					 echo Key is already installed. Skipping
		fi
CHECK_KEY

	     print " Command $command " if ($DEBUG);

		  my $stdout = $ssh->exec($command);

		  warn "$host: $stdout \n" if ($stdout);

		  $ssh->close();


}

# ************ Some support subroutines...
sub get_users_from_config {
  my $configfile = shift;

  my $config = slurp($configfile);

  $config =~ s/\n\s*#.*//g;
  $config =~ s/^\s*$//;

  my @config = split /\s*Host\s+/, $config;
  shift @config;

  return  map { parse_entry($_) }  @config;

}

sub parse_entry {
  my $entry = shift;

  my @entry = split /\n/, $entry;
  my $alias = shift @entry;
  my @alias = split /\s+/, $alias;

  my %config = map { split(/[ \t]+/, $_, 2) } @entry;

  map { ($_, \%config) } @alias;

}

sub slurp {
  my $file = shift;

  open (my $fh, "<", $file);
  local $/ = undef;
  my $input = <$fh>;
  close $fh;

  return $input;
}

sub man {
	pod2usage(-exitval => 1, -verbose => 2);
}


package Net::SSH::Expect;

no warnings 'redefine';
sub login {

    my Net::SSH::Expect $self = shift;

	# setting the default values for the parameters
    my ($login_prompt, $password_prompt, $test_success) = ( qr/ogin:\s*$/, qr/[Pp]assword.*?:|[Pp]assphrase.*?:/, 0);
	
	# attributing the user defined values
	if (@_ == 2 || @_ == 3) {
		$login_prompt = shift;
		$password_prompt = shift;
	}
	if (@_ == 1) {
		$test_success = shift;
	}

	my $user = $self->{user};
	my $password = $self->{password};
	my $timeout = $self->{timeout};
	my $t = $self->{terminator};

	croak(ILLEGAL_STATE . " field 'user' is not set.") unless $user;
	croak(ILLEGAL_STATE . " field 'password' is not set.") unless $password;

	# spawns the ssh process if this wasn't done yet
	if (! defined($self->{expect})) {
		$self->run_ssh() or croak SSH_PROCESS_ERROR . " Couldn't start ssh: $!\n";
	}

	my $exp = $self->get_expect();

	# loggin in
	$self->_sec_expect($timeout,
		[ qr/\(yes\/no\)\?\s*$/ => sub { $exp->send("yes$t"); exp_continue; } ],
		[ $password_prompt		=> sub { $exp->send("$password$t"); } ],
		[ qr/\$/		=> sub { print " Logged withouth password \n"; print "--> ".$self->peek()."\n"; } ],
		[ $login_prompt         => sub { $exp->send("$user$t"); exp_continue; } ],
		[ qr/REMOTE HOST IDEN/  => sub { print "FIX: .ssh/known_hosts\n"; exp_continue; } ],
		[ qr/ssh:/ => sub { print "SSH Error: ".$self->peek()."\n"; croak "SSH Error";} ],
		[ timeout => sub 
			{ 
				croak SSH_AUTHENTICATION_ERROR . " Login timed out. " .
				"The input stream currently has the contents bellow: " .
				$self->peek() if (not $self->peek() =~ qr/$/);
				print " Timeout " if ($DEBUG);
			} 
		]
	);
	# verifying if we failed to logon
	if ($test_success) {
		$self->_sec_expect($timeout, 
			[ $password_prompt  => 			
				sub { 
					my $error = $self->peek();
					croak(SSH_AUTHENTICATION_ERROR . " Error: Bad password [$error]");
				}
			]
		);
	}
	print " Exit OK \n" if ($DEBUG);
   	# swallows any output the server wrote to my input stream after loging in	
	my $output = $self->read_all(1);
	print "--->: ".$output."\n" if ($DEBUG);
	return 1;
}
# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Net::SSH::CopyId - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Net::SSH::CopyId;

=head1 DESCRIPTION

We are still working on this

=head2 EXPORT




=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Programacion en Paralelo II, E<lt>pp2@E<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Programacion en Paralelo II

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
