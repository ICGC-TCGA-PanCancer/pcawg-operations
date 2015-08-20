#!/bin/bash
# A cron script to update the Sanger variant calling blacklist once daily

# Find the gnos_repo_summary
time_stamp=$(date '+20%y-%m-%d')
paths=/mnt/data/pancancer-sandbox/pcawg_metadata_parser/gnos_metadata/${time_stamp}*UTC/reports/gnos_repo_summary
len=${#paths[@]}

last=$((len - 1)) 
echo $paths
path=${paths[$last]}

if [[ ! -n $path ]] 
then 
    echo "Panic! No PATH!"
fi

echo switching to path $path
cd $path
pwd=$(pwd);

if [[ ! "$path" == "$pwd" ]]
then
    echo "ERROR: we have no metadata path!"
    echo path|${path}|
    echo -pwd|${pwd}|
    exit 1
fi

echo in path $pwd

time_stamp=$(date '+%y%m%d-%H%M')
cat live_sanger_variant_called_donors.*.txt > _all_sites.$time_stamp.sanger_variant_called_donors.txt

list=$(wc -l  _all_sites.$time_stamp.sanger_variant_called_donors.txt)
echo The new file has $list lines

export PATH=${PATH}:/usr/local/bin

# have to delete and reclone working copy of repo each day 
# for automated authentication to work
cd /mnt/data/
rm -fr pcawg-operations
git clone git@github.com:ICGC-TCGA-PanCancer/pcawg-operations.git

cd $path

mv _all_sites.$time_stamp.sanger_variant_called_donors.txt \
    /mnt/data/pcawg-operations/variant_calling/sanger_workflow/blacklists/_all_sites

cd /mnt/data/pcawg-operations/variant_calling/sanger_workflow/blacklists/_all_sites

cat _all_sites.$time_stamp.sanger_variant_called_donors.txt \
    annotation.150226-1002.alignment_failed_manual_curation.txt \
    annotation.150226-1003.alignment_failed_qc.txt \
    annotation.150409-1401.esad-uk_header_issue.txt \
    annotation.150527-1404.esad-uk_header_issue.txt \
    annotation.150626-1141.esad-uk_header_issue.txt \
    annotation.150629-1137.paca-au_header_issue.txt \
    annotation.150630-1556.esad-uk_header_issue.txt \
    annotation.150811-1217.alignment_failed_qc.txt \
    annotation.150820-1159.esad-uk_normal_tumor_same.txt \
    pdc1_1.150114-2103.pilot-63.txt | sort | uniq \
    > _all_sites.$time_stamp.merged_called-donors-pilot63-annotation.txt

ln -s -f  _all_sites.$time_stamp.merged_called-donors-pilot63-annotation.txt \
    _all_sites.latest_blacklist.txt

list=$(wc -l  _all_sites.latest_blacklist.txt)
echo The new blacklist has $list entries

echo /mnt/data/pcawg-operations/variant_calling/sanger_workflow/blacklists/_all_sites

# Then it's just a matter of pushing the list to git and tagging it with the date
git add .
git commit -m 'updated blacklist'
git push

# use the github API to tag and release the new blacklist
time_stamp=$(date '+20%y-%m-%d')
/home/ubuntu/blacklist/release.pl $time_stamp



