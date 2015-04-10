#!/usr/bin/perl
#
# File: reformat_train2_gdocs.pl by Marc Perry
# 
# This script reads in a .tsv GoogleDocs spreadsheet and
# saves certain columns, gives them new headers, and then 
# prints out a new .tsv file
# 
# Last Updated: 2015-04-10, Status: seems to work as advertised

use strict;
use warnings;
use Data::Dumper;

die "USAGE: $0 <GoogleDocs_table_converted.tsv>" unless $ARGV[0];

my @fields;
my $gtable = shift;
open my ($GTABLE), '<', $gtable or die "Could not open $gtable for reading";

my $header = <$GTABLE>;  
chomp $header;

my @column_headers = split(/\t/, $header);
my %projects;

while ( <$GTABLE> ) {
    chomp;
    my %records; 
    @records{@column_headers} = split(/\t/, $_); # a hash slice 
    my $dcc_project_code = $records{'Project Code'};
    my $submitter_donor_id = $records{'Donor ID'};
    my $normal_aliquot_id = $records{'Normal Analyzed Sample/Aliquot GUUID'};
    my $normal_aligned_bam_gnos_url = $records{'Normal GNOS endpoint'} . 'cghub/metadata/analysisFull/' . $records{'Normal Analysis ID'};
    my $tumor_aliquot_id = $records{'Tumour Analyzed Sample/Aliquot GUUID'};
    my $tumor_aligned_bam_gnos_urls = $records{'Tumour GNOS endpoint'} . 'cghub/metadata/analysisFull/' . $records{'Tumour Analysis ID'};
    push @{$projects{$dcc_project_code}{$submitter_donor_id}{$normal_aliquot_id}{$normal_aligned_bam_gnos_url}{t_aliquot}}, $tumor_aliquot_id;
    push @{$projects{$dcc_project_code}{$submitter_donor_id}{$normal_aliquot_id}{$normal_aligned_bam_gnos_url}{t_url}}, $tumor_aligned_bam_gnos_urls;

} # close while loop

# print Data::Dumper->new([\%projects],[qw(projects)])->Indent(1)->Quotekeys(0)->Dump, "\n";

close $GTABLE;
my @now = localtime();
my $timestamp = sprintf( "%04d_%02d_%02d_%02d%02d", $now[5]+1900, $now[4]+1, $now[3], $now[2], $now[1], );

open my ($OUT), '>', 'Data_Freeze_Train_2.0_GoogleDocs__' . "$timestamp" . '.tsv' or die "Could not open output file for writing.";

print {$OUT} "dcc_project_code\tsubmitter_donor_id\tnormal_aliquot_id\tnormal_aligned_bam_gnos_url\tnumber_of_tumor_samples\ttumor_aliquot_id\ttumor_aligned_bam_gnos_urls\n";

# printing loop
foreach my $project ( sort keys %projects ) {
    foreach my $donor ( sort keys %{$projects{$project}} ) {
        my ( $n_aliquot, $value1, ) = each %{$projects{$project}{$donor}};
        my ( $n_url, $value2, )  = each %{$projects{$project}{$donor}{$n_aliquot}};
        my $tumor_count = scalar( @{$projects{$project}{$donor}{$n_aliquot}{$n_url}{t_aliquot}} );
        my ( $t_aliquot, $t_url, ); 
        if ( $tumor_count > 1 ) {
            $t_aliquot = join( ',', @{$projects{$project}{$donor}{$n_aliquot}{$n_url}{t_aliquot}} );
            $t_url = join( ',', @{$projects{$project}{$donor}{$n_aliquot}{$n_url}{t_url}} );
	}
        else {
            $t_aliquot = $projects{$project}{$donor}{$n_aliquot}{$n_url}{t_aliquot}[0];
            $t_url = $projects{$project}{$donor}{$n_aliquot}{$n_url}{t_url}[0];
        }
        print {$OUT} "$project\t$donor\t$n_aliquot\t$n_url\t$tumor_count\t$t_aliquot\t$t_url\n";
    } # close 2nd foreach loop
} # close outer foreach loop

close $OUT;

exit;

__END__

