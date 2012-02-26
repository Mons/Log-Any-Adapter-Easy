#!/usr/bin/env perl -w

use common::sense;
use lib::abs '../lib';
use Test::More tests => 2;
use Test::NoWarnings;

BEGIN {
	use_ok( 'Log::Any::Adapter::Easy' );
}

diag( "Testing Log::Any::Adapter::Easy $Log::Any::Adapter::Easy::VERSION, Perl $], $^X" );
