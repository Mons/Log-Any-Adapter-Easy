package Log::Any::Adapter::Easy::Screen;

use 5.008008;
use common::sense 2;m{
use strict;
use warnings;
};
use Carp;

use Log::Any ();
use parent qw(Log::Any::Adapter::Core);

sub new { bless {@_},shift }

=for rem

        $self->{color}  = exists $p{color} ? $p{color}  : {
            '' => { fg => 'white', ex => 'dark' }, # default,
            emergency => { fg => 'white', bg => 'red', ex => 'bold,underline' },
            alert     => { fg => 'red',                ex => 'bold,underline' },
            critical  => { fg => 'red',                ex => 'dark,underline' },

            error     => { fg => 'red', },

            warning   => { fg => 'yellow', ex => 'bold', },
            notice    => { fg => 'yellow', ex => 'dark', },

            info      => { fg => 'white',  ex => 'bold', },
            debug     => { fg => 'white',  ex => 'dark' },
            
            stats     => { fg => 'black', bg => 'green', },
            access    => { fg => 'black', bg => 'white', },
        };

=cut

our %COLOR = (
	trace     => "36",
	debug     => "37",
	info      => "1;37",
	notice    => "33",
	warning   => "1;33",
	error     => "31",
	critical  => "4;31",
	alert     => "1;31",
	emergency => "1;37;41",
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
				if (-t $fh) {
					print {$fh} "\e[".( $COLOR{$method} || 0 )."m";
				}
				print {$fh} "[\U$method\E] ".$msg;
				if (-t $fh) {
					print {$fh} "\e[0m";
				}
				print {$fh} "\n";
			}
		};
	}
}



1;
