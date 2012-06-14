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
use Scalar::Util 'weaken';

our $SINGLE;

sub new {
	my $pkg = shift;
	$SINGLE and return my $new = $SINGLE;
	my $self = bless {
		facility => 'user',
		logopt   => 'ndelay,nofatal,nowait,pid',
		@_
	},$pkg;
	$self->{name} //= delete ($self->{ident}) // do {
		my ($n) = $0 =~ m{([^/]+)$}s;
		$n;
	};
	
	#$SINGLE and croak "Can't create 2 instances of $pkg: syslog restriction";
	#warn "create syslog $self->{name}: ($self->{logopt}) -> $self->{facility}";
	weaken( $SINGLE = $self );
	Sys::Syslog::openlog($self->{name}, $self->{logopt}, $self->{facility});
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
			{
				no warnings 'utf8';
				#warn "call syslog";
				Sys::Syslog::syslog( $LEVEL{$method} // LOG_INFO, "%s", $msg );
			}
		};
	}
}

sub DESTROY {
	my $self = shift;
	#warn "destroy syslog $self->{name}: ($self->{logopt}) -> $self->{facility}";
	Sys::Syslog::closelog();
}


1;
