#!/usr/bin/env perl

use uni::perl;
use lib::abs '../lib','../../../..';
#use Log::Any::Adapter::Easy qw(+screen -syslog);
use Log::Any::Adapter::Easy qw(+screen +syslog);
#use Log::Any::Adapter::Easy qw(+screen +syslog) => { name => 'sample', logopt => 'ndelay,nofatal,nowait,pid', facility => 'local0'  };
use Log::Any '$log';

for my $m (grep { !/emerg/i } Log::Any->logging_methods, Log::Any->logging_aliases) {
	$log->$m("test $m");
}

Log::Any::Adapter::Easy->syslog( { name => 'sample', logopt => 'ndelay,nofatal,nowait,pid', facility => 'local0' } );

for my $m (grep { !/emerg/i } Log::Any->logging_methods, Log::Any->logging_aliases) {
	$log->$m("test $m");
}

Log::Any::Adapter::Easy->syslog( { name => 'another', facility => 'user' } );

for my $m (grep { !/emerg/i } Log::Any->logging_methods, Log::Any->logging_aliases) {
	$log->$m("test $m");
}
