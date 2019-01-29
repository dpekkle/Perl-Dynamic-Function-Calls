#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/";

require entity::job;
my $job = entity::job->new();

printf "Job Default Status: %s\n" , $job->get_default_status('upper');

require entity::sale;
my $sale = entity::sale->new();

printf "Sale Default Status: %s\n" , $sale->get_default_status('upper');
