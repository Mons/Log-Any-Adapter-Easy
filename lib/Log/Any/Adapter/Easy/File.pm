package Log::Any::Adapter::Easy::File;

use 5.008008;
use common::sense 2;m{
use strict;
use warnings;
};
use Carp;

use Log::Any ();
use parent qw(Log::Any::Adapter::Core);

sub new {
	my $self = bless {@_},shift;
	$self;
}

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
				# TODO
			}
		};
	}
}



1;
