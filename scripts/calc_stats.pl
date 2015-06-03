use strict;
use JSON;
use Data::Dumper;
$|++;

# bin <- read.csv(file="in_whitelist.bwa.tsv", sep="\t", head=TRUE)
# bout <- read.csv(file="out_whitelist.bwa.tsv", sep="\t", head=TRUE)
# sin <- read.csv(file="in_whitelist.sanger.tsv", sep="\t", head=TRUE)
# sout <- read.csv(file="out_whitelist.sanger.tsv", sep="\t", head=TRUE)
# perl calc_stats.pl donor_p_150319022850.jsonl master.whitelist.txt in_whitelist.bwa.tsv out_whitelist.bwa.tsv in_whitelist.sanger.tsv out_whitelist.sanger.tsv

my ($file, $whitelist, $in_list_bwa_output, $out_list_bwa_output, $in_list_sanger_output, $out_list_sanger_output) = @ARGV;

my $json = JSON->new->allow_nonref;

open OUTIN, ">$in_list_bwa_output" or die;
open OUTOUT, ">$out_list_bwa_output" or die;
open OUTINS, ">$in_list_sanger_output" or die;
open OUTOUTS, ">$out_list_sanger_output" or die;

open IN, "<$file" or die;

open WHITE, "<$whitelist" or die;
my $white = {};
while(<WHITE>) {
  chomp;
  my @a = split /\s+/;
  $white->{$a[0]}{$a[1]} = 1;
}
close WHITE;

my ($merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds);


print OUTIN join("\t", ("Project", "Donor", "Merge", "BWA", "QC", "Download", "TotalNoQC"));
print OUTIN "\n";
print OUTOUT join("\t", ("Project", "Donor", "Merge", "BWA", "QC", "Download", "TotalNoQC"));
print OUTOUT "\n";


print OUTINS join("\t", ("Project", "Donor", "Sanger"));
print OUTINS "\n";
print OUTOUTS join("\t", ("Project", "Donor", "Sanger"));
print OUTOUTS "\n";

my $i;
while (<IN>) {
  chomp;
  $i++;
  if ($i%100 == 0) { print "."; }
  my $json_obj = $json->decode($_);
  #print Dumper($json_obj);
  my $variant_timing = $json_obj->{variant_calling_results}{sanger_variant_calling}{workflow_details}{variant_timing_metrics}{workflow}{Wall_s};
  if ($variant_timing == 0 && $_ =~ /SangerPancancerCgpCnIndelSnvStr/) {
    print Dumper($json_obj); die;
  }
  my $dcc_project_code = $json_obj->{dcc_project_code};
  my $submitter_donor_id = $json_obj->{submitter_donor_id};
  #print Dumper($json_obj->{normal_specimen}{alignment}{timing_metrics});
  ($merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds) = sum_stats($json_obj->{normal_specimen}{alignment}{timing_metrics}, $merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds);
  foreach my $tumor_hash (@{$json_obj->{aligned_tumor_specimens}}) {
    #print Dumper($tumor_hash->{alignment}{timing_metrics});
    ($merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds) = sum_stats($tumor_hash->{alignment}{timing_metrics}, $merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds);
  }
  #my $total = $merge_timing_seconds + $bwa_timing_seconds + $qc_timing_seconds + $download_timing_seconds;
  my $total = $merge_timing_seconds + $bwa_timing_seconds + $download_timing_seconds;
  my $total_hours = $total / 3600;

  # skip anything with missing data
  next if ($total == 0 || $merge_timing_seconds == 0 || $bwa_timing_seconds == 0 || $download_timing_seconds == 0);

  #print join("\t", ("Merge:", $merge_timing_seconds, "BWA:", $bwa_timing_seconds, "QC:", $qc_timing_seconds, "Download:", $download_timing_seconds, "Total:", $total));
  #print "\n";
  #print join("\t", ("Merge:", $merge_timing_seconds/3600, "BWA:", $bwa_timing_seconds/3600, "QC:", $qc_timing_seconds/3600, "Download:", $download_timing_seconds/3600, "Total:", $total_hours));
  if ($white->{$dcc_project_code}{$submitter_donor_id}) {
    print OUTIN join("\t", ($dcc_project_code, $submitter_donor_id, $merge_timing_seconds/3600, $bwa_timing_seconds/3600, $qc_timing_seconds/3600, $download_timing_seconds/3600, $total_hours)), "\n";
    if ($variant_timing > 0) {
      print OUTINS join("\t", ($dcc_project_code, $submitter_donor_id, $variant_timing/3600)), "\n";
    }
  } else {
    print OUTOUT join("\t", ($dcc_project_code, $submitter_donor_id, $merge_timing_seconds/3600, $bwa_timing_seconds/3600, $qc_timing_seconds/3600, $download_timing_seconds/3600, $total_hours)), "\n";
    if ($variant_timing > 0) {
      print OUTOUTS join("\t", ($dcc_project_code, $submitter_donor_id, $variant_timing/3600)), "\n";
    }
  }
  $merge_timing_seconds = 0;
  $bwa_timing_seconds = 0;
  $qc_timing_seconds = 0;
  $download_timing_seconds = 0;
}
print "\nDONE!\n";

close OUTIN;
close OUTOUT;
close OUTINS;
close OUTOUTS;
close IN;

sub sum_stats {
  my ($hash, $merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds) = @_;

  foreach my $metrics (@{$hash}) {
    $merge_timing_seconds = $metrics->{metrics}{merge_timing_seconds};
    $bwa_timing_seconds += $metrics->{metrics}{bwa_timing_seconds};
    $qc_timing_seconds += $metrics->{metrics}{qc_timing_seconds};
    $download_timing_seconds += $metrics->{metrics}{download_timing_seconds};
  }
  return($merge_timing_seconds, $bwa_timing_seconds, $qc_timing_seconds, $download_timing_seconds);
}
