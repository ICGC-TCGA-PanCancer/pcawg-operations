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
cd /mnt/data/
rm -fr pcawg-operations
git clone git@github.com:ICGC-TCGA-PaCancer/pcawg-operations.git
#git clone git@github.com:mckays630/pcawg-operations.git  
cd $path

mv _all_sites.$time_stamp.sanger_variant_called_donors.txt \
    /mnt/data/pcawg-operations/variant_calling/sanger_workflow/blacklists/_all_sites

cd /mnt/data/pcawg-operations/variant_calling/sanger_workflow/blacklists/_all_sites

cat _all_sites.$time_stamp.sanger_variant_called_donors.txt \
    annotation.150226-0955.DE_wrong_quality_score.txt \
    annotation.150226-1002.alignment_failed_manual_curation.txt \
    annotation.150226-1003.alignment_failed_qc.txt \
    annotation.150308-1807.waiting_for_annai_unsuppress.txt \
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



