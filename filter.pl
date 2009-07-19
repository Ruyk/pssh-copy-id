#!/usr/bin/perl -w
# See:
# make wiki
# in Makefile.PL
# This is script is to fix some bugs
# in # Pod::Simple::Wiki::Googlecode
use strict;

local $/ = undef;
$_ = <>;
s/\{\{\{/{{{\n/g;
s/\}\}\}/\n}}}/g;
print;
