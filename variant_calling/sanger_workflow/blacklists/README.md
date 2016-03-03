# Blacklists for Sanger Variant Calling Workflow 


## Overview

A blacklist contains list of donors that are not to be used for calling variants by Sanger Variant Calling Workflow.

The most important reason a blacklist is used is to ensure all compute sites will not unintentionally schedule any donor that has already be variant called or any donor that is not suitable for variant calling.

## Rules for creating / using blacklists

Overall, the rules for creating / using blacklists is very similar to that of whitelists, see README in whitelists directory for details.

One very important different blacklist has compared to whitelist is that, it's very typically for all compute sites use the same blacklist. There is no need to prepare compute site specific blacklist. For this very reason, generating blacklist for Sanger variant called donors is almost trivial. It can be fully automated the same way as how various of report tables are produced.

We can generate blacklist as often as hourly, so it should be able to very effectively prevent compute sites from scheduling donors that have already been called in any compute site and submitted the call result to a GNOS repo.

We use the directory named '\_all\_sites' to hold blacklists that are applicable to all compute sites. Compute site specific blacklist is still possible to have, just put them in the directory named after the compute site, all file naming conventions are the same as whitelist.


<b>./scripts</b> contains scripts used to automatically update the blacklist once daily using this crontab
<pre>1 4 * * * sudo -u ubuntu bash /home/ubuntu/blacklist/update_blacklist.sh >> /home/ubuntu/logs/blacklist.log 2>&1</pre>
