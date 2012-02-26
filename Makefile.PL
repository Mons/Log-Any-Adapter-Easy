use inc::Module::Install;

my $MI  = $Module::Install::MAIN;
name           'Log-Any-Adapter-Easy';
all_from       'lib/Log/Any/Adapter/Easy.pm';
author         'Mons Anderson <mons@cpan.org>';
license        'perl';

build_requires 'Test::More';
build_requires 'lib::abs',  '0.90';

requires 'common::sense',    2;
requires 'Log::Any';
requires 'Log::Any::Adapter';

auto_provides;
auto_install;

WriteAll;

print STDERR "Generated makefile for ".$MI->load('name')->name."-".$MI->load('version')->version."\n";
