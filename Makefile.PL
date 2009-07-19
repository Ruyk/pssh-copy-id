use warnings;
use strict;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

my $MACHINES = $ENV{MACHINES} || '127.0.0.1 127.0.0.2';
my @exe_files = map { "script/$_" } qw{pssh-copy-id};
WriteMakefile(
    NAME              => 'Net::SSH::CopyId',
    VERSION_FROM      => 'lib/Net/SSH/CopyId.pm', # finds $VERSION
    PREREQ_PM         => { 'Net::SSH::Expect' => '0', 'Term::ReadPassword' => '0', 'Net::HostLanguage' => '0' }, # e.g., Module::Name => 1.1
    EXE_FILES         => [ @exe_files ],
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Net/SSH/CopyId.pm', # retrieve abstract from module
       AUTHOR         => 'Ruymán Reyes <namiurtf@gmail.com>') : ()),
);

sub MY::postamble {

  return '' unless defined($ENV{DEVELOPER});

  $_ = targets();
  s/<<MACHINES>>/$MACHINES/g;

  return $_;
}

sub targets {
  return <<'EOSQT';

PLTAGS=/usr/share/vim/vim71/tools/pltags.pl

coverage:
	 cover -delete
	make HARNESS_PERL_SWITCHES=-MDevel::Cover test
	cover

.PHONY: tags
tags: 
	${PLTAGS} script/pssh-copy-id lib/Net/SSH/CopyId.pm 
	ctags -a --exclude=examples --exclude=t --exclude=doc --exclude=tt2

remotetest:
	remotetest.pl ${DISTVNAME}.tar.gz <<MACHINES>>

wiki:
	# Pod::Simple::Wiki::Googlecode
	pod2wiki --style googlecode script/pssh-copy-id | ./filter.pl > pssh-copy-id.wiki

EOSQT

}

