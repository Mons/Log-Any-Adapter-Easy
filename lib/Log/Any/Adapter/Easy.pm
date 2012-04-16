package Log::Any::Adapter::Easy;

use 5.008008;
use common::sense 2;m{
use strict;
use warnings;
};
use Carp;
use Log::Any::Adapter ();
use parent qw(Log::Any::Adapter::Base);
use Scalar::Util 'weaken';
#use Log::Any::Adapter::Easy::Screen;
#use Log::Any::Adapter::Easy::Syslog;

=head1 NAME

Log::Any::Adapter::Easy - ...

=cut

our $VERSION = '0.01'; $VERSION = eval($VERSION);

=head1 SYNOPSIS

    package Sample;
    use Log::Any::Adapter::Easy;

    ...

=head1 DESCRIPTION

    ...

=cut

our %logs = ( ( map {$_ => 1} qw(screen) ), (map { $_ => 0 } qw(syslog file)) );
our $SINGLE;

sub import {
	my $pk = shift;
	my %args = %logs;
	while (@_) {
		my $key = shift;
		if ($key =~ s{^-}{}) {
			if (!exists $logs{$key}) {
				carp "Don't know log type $key";
			}
			next;
		}
		$key =~ s{^\+}{};
		if (!exists $logs{$key}) {
			carp "Don't know log type $key";
		}
		my $next = @_ && $_[0];
		$next =~ s{^[+-]}{}s;
		if (exists $logs{$next}){ next };
		$args{$key} = shift;
	}
	Log::Any::Adapter->set('Easy', %args);
}

sub init {
	my $self = shift;
	#warn "init (@_) ";
	$SINGLE and croak "Duplicate initialization of Easy adapter";
	weaken ( $SINGLE = $self );
	my %args = @_;
	if ($self->{screen}) {
		$self->screen( $self->{screen} );
	}
	if ($self->{syslog}) {
		$self->syslog( $self->{syslog} );
	}
	if ($self->{file}) {
		$self->file( $self->{file} );
	}
	if (!@{ $self->{logs} ||=[] }) {
		croak "Selected no output methods";
	}
	return;
}

sub screen {
	my $self = shift;
	ref $self or $self = $SINGLE or die "No adapter initialized";
	$self->{screen} = @_ ? shift : 1;
	if(!$self->{screen}) {
		delete $self->{screen};
	}
	if( eval { require Log::Any::Adapter::Easy::Screen; 1 } ) {
		$self->{screen} = Log::Any::Adapter::Easy::Screen->new( $self->{screen} eq "1" ? () : %{ $self->{screen} } );
		push @{ $self->{logs} ||=[] }, $self->{screen};
		weaken( $self->{logs}[-1] );
	} else {
		carp "Can't load screen logger: $@";
	}
}

sub syslog {
	my $self = shift;
	ref $self or $self = $SINGLE or die "No adapter initialized";
	$self->{syslog} = @_ ? shift : 1;
	if(!$self->{syslog}) {
		delete $self->{syslog};
	}
	if( eval { require Log::Any::Adapter::Easy::Syslog; 1 } ) {
		$self->{syslog} = Log::Any::Adapter::Easy::Syslog->new( $self->{syslog} eq "1" ? () : %{ $self->{syslog} } );
		push @{ $self->{logs} ||=[] }, $self->{syslog};
		weaken( $self->{logs}[-1] );
	} else {
		carp "Can't load syslog logger: $@";
	}
}

sub file {
	my $self = shift;
	ref $self or $self = $SINGLE or die "No adapter initialized";
	$self->{file} = @_ ? shift : 1;
	if(!$self->{file}) {
		delete $self->{file};
	}
	if( eval { require Log::Any::Adapter::Easy::File; 1 } ) {
		$self->{syslog} = Log::Any::Adapter::Easy::File->new( $self->{file} eq "1" ? () : %{ $self->{file} } );
		push @{ $self->{logs} ||=[] }, $self->{file};
		weaken( $self->{logs}[-1] );
	} else {
		carp "Can't load file logger: $@";
	}
}


{
	no strict 'refs';
	for my $method ( Log::Any->logging_methods() ) {
		*$method = sub {
			my $self = shift;
			my $msg = shift;
			if (@_ and index($msg,'%') > -1) {
				$msg = sprintf $msg, @_;
			}
			$msg =~ s{\n*$}{\n};
			{
				no warnings 'utf8';
				for ( @{$self->{logs}} ) {
					$_ or next;
					eval{ $_->$method($msg); 1 } or carp "$@";
				};
			}
		};
	}
	for my $method ( Log::Any->detection_methods() ) {
		no strict 'refs';
		*$method = sub () { 1 };
	}
}

sub DESTROY {}

=head1 AUTHOR

Mons Anderson, C<< <mons@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Mons Anderson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

=cut

1;
