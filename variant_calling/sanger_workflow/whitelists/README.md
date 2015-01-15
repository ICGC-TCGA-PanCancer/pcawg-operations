# Whitelists for Sanger Variant Calling Workflow

## Overview

A whitelist contains list of donors with complete set of aligned BAMs that are ready for calling variants by Sanger Variant Calling Workflow.

Whitelists are used for a few reasons:
- Centrally managed whitelists assure different compute sites will not unintentionally schedule the same donors
- Ensure only donors with complete set of aligned BAMs are to be scheduled to run
- Provide some flexibility to allow us give priority to certain groups of donors, such as Pilot-63

## Rules for creating / using whitelists

### Directory structure and naming convention

Below is an example of directory structure and some whitelists:

```
└── whitelists
    ├── README.md
    ├── bsc
    ├── dkfz
    ├── ebi
    ├── etri
    │   └── etri.150109-1245.second_half_of_clle-es.txt
    ├── frankfurt
    ├── ireland
    ├── oicr
    │   └── oicr.150109-1245.first_half_of_clle-es.txt
    ├── pdc1_1
    │   └── pdc1_1.150101-1010.pilot-63.txt
    ├── pdc2_0
    ├── tokyo
    ├── ucsc
    └── virginia
```

Each directory under *whitelists* is named after the compute site, it contains whitelist(s) for the named compute site.

A whitelist file must follow the following naming convention:
```
<compute_site>.<yymmdd-hhmm>.[optional text as comments<.>]<txt>
```

Note that \<compute_site\> must match the name of directory the whitelist is currently under.

### Content of whitelist

Whitelists are plain text files. Each row is a donor that is uniquely identified by *dcc\_project\_code* and *submitter\_donor\_id*. These two fields are joined by a tab '\t', e.g., PRAD-UK  0065\_CRUK\_PC\_0065

### Rules for creating / maintaining whitelists

Multiple whitelist files can co-exist for the same compute site, however, only the latest one is used. This means that when a new whitelist is needed for a compute site, we simply create a new list and leave the previously used whitelist unchanged (and kept around for auditing purpose). The way we can tell which whitelist is newer is by checking the \<yymmdd-hhmm\> part of the file name, newer whitelist has newer timestamp in its name. In practice, we just need to sort all the whitelist files by default order, the last file will be the current (in use) whitelist.

Important: to allow better traceability and auditing, it is strongly suggested to not change (changing content, renaming or deleting) a whitelist once it is created and committed to GIT. If you have to make correction to a whitelist, simply create a new one with newer timestamp in the file name.

### Rules for consuming whitelists

Each compute site will checkout the *pcawg-operations* GIT repo, and periodically run *git pull* to update its local content. The *decider* in a compute site follows directory structure and naming convention to locate the directory containing its whitelist(s). Then it finds all whitelist(s) by checking file names, and identify the latest one and uses it.

