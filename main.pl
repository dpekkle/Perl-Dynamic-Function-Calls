#!/usr/bin/perl
use FindBin;
use lib "$FindBin::Bin/";

require entity::job;
my $job = entity::job->new();

print "\nJob Default Status: " . $job->get_default_status('upper');

require entity::sale;
my $sale = entity::sale->new();

print "\nSale Default Status: ". $sale->get_default_status('upper');