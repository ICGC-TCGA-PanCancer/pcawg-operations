#!/usr/bin/perl -w
use common::sense;
use Net::GitHub;
use Data::Dumper;


use constant USER  => 'ICGC-TCGA-PanCancer';

my $time_stamp = shift or die "I need a timestamp!";

my $gh = Net::GitHub::V3->new(login => USER, access_token => token()); 

$gh->set_default_user_repo(USER, 'pcawg-operations');

my $repo = $gh->repos;

my $data = {
  "tag_name" => $time_stamp,
  "target_commitish" => "develop",
  "name" => $time_stamp,
  "body" => "Blacklist release for $time_stamp"
};

my $rel = $repo->create_release($data);

say Dumper $rel;


sub token {
    open T, "$ENV{HOME}/.release";
    my $TOKEN;
    while (<T>) {
	chomp;
	$TOKEN=$_;
	last if $TOKEN;
    }
    return $TOKEN;
}
