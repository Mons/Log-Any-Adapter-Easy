package Log::Any::Adapter::Easy;

use 5.008008;
use common::sense 2;m{
use strict;
use warnings;
};
use Carp;
use Log::Any::Adapter ();
use parent qw(Log::Any::Adapter::Base);
use Log::Any::Adapter::Easy::Screen;
use Log::Any::Adapter::Easy::Syslog;

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
	my %args = @_;
	#use uni::perl ':dumper';
	#warn "init @_".dumper $self;
	if ($self->{screen}) {
		if( eval { require Log::Any::Adapter::Easy::Screen; 1 } ) {
			$self->{screen} = Log::Any::Adapter::Easy::Screen->new( $self->{screen} eq "1" ? () : %{ $self->{screen} } );
			push @{ $self->{logs} ||=[] }, $self->{screen};
		} else {
			carp "Can't load screen logger: $@";
		}
	}
	if ($self->{syslog}) {
		if( eval { require Log::Any::Adapter::Easy::Syslog; 1 } ) {
			$self->{syslog} = Log::Any::Adapter::Easy::Syslog->new( $self->{syslog} eq "1" ? () : %{ $self->{syslog} } );
			push @{ $self->{logs} ||=[] }, $self->{syslog};
		} else {
			carp "Can't load syslog logger: $@";
		}
	}
	if ($self->{file}) {
		if( eval { require Log::Any::Adapter::Easy::File; 1 } ) {
			$self->{syslog} = Log::Any::Adapter::Easy::File->new( $self->{file} eq "1" ? () : %{ $self->{file} } );
			push @{ $self->{logs} ||=[] }, $self->{file};
		} else {
			carp "Can't load syslog logger: $@";
		}
	}
	return;
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
				eval{ $_->$method($msg); 1 } or carp "$@" for @{$self->{logs}};
			}
		};
	}
	for my $method ( Log::Any->detection_methods() ) {
		no strict 'refs';
		*$method = sub () { 1 };
	}
}

=head1 AUTHOR

Mons Anderson, C<< <mons@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2012 Mons Anderson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

=cut

1;
