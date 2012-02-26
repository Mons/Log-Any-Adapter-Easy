package Log::Any::Adapter::Easy::Syslog;

use 5.008008;
use common::sense 2;m{
use strict;
use warnings;
};
use Carp;

use Log::Any ();
use parent qw(Log::Any::Adapter::Core);
use Sys::Syslog ':standard', ':macros';

sub new {
	my $pkg = shift;
	my $self = bless {@_},$pkg;
	$self->{name} //= do {
		my ($n) = $0 =~ m{([^/]+)$}s;
		$n;
	};
	openlog($self->{name},'',LOG_USER);
	$self;
}

our %LEVEL = (
	trace     => LOG_DEBUG,
	debug     => LOG_DEBUG,
	info      => LOG_INFO,
	notice    => LOG_NOTICE,
	warning   => LOG_WARNING,
	error     => LOG_ERR,
	critical  => LOG_CRIT,
	alert     => LOG_ALERT,
	emergency => LOG_EMERG,
);

{
	no strict 'refs';
	for my $method ( Log::Any->logging_methods() ) {
		*$method = sub {
			shift;
			my $msg = shift;
			if (@_ and index($msg,'%') > -1) {
				$msg = sprintf $msg, @_;
			}
			$msg =~ s{\n*$}{};
			my $fh = \*STDOUT;
			{
				no warnings 'utf8';
				syslog( $LEVEL{$method} // LOG_INFO, "%s", $msg );
			}
		};
	}
}



1;
