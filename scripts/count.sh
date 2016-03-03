#!/bin/bash

for i in variant_calling/sanger_workflow/whitelists/*; do echo $i; grep -f variant_calling/sanger_workflow/blacklists/_all_sites/_all_sites.latest_blacklist.txt $i/*.txt | awk -F ':' '{print $2}' | sort | uniq | wc -l; grep -v -f variant_calling/sanger_workflow/blacklists/_all_sites/_all_sites.latest_blacklist.txt $i/*.txt | awk -F ':' '{print $2}' | sort | uniq | wc -l; done;

