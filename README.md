# `site.md`
A markdown website auto builder.

Full documentation at [docs.rose-brindle.dev]().

## Details
This script (`sitemd.sh`) creates PHP files based on the given template for all markdown files in either the root directory (ie the directory the script is in), or recurisvely within all directories within the root directory. A config file is automaticly created within each directory which stores useful data for the PHP files. A main config file (`sitemd_conf.json`) allows the user to make configuration changes.

## `sitemd.sh` Command
### Usage
> `./sitemd.sh [-m <'update' | 'hardupdate' | 'clear'>] [-t </template/file/location.php>] [-c <root config filename, default='sitemd_conf'>] [-r]`
### Mode
Option: -m

Required: Yes

Must be either `update`, `hardupdate` or `clear`. 

`clear` removes all PHP files

`hardupdate` removes all PHP files and recreates them from the given template, and creates directory config files as required

`update` creates PHP files from the given template if they are not present, and creates directory config files as required

### Template Address
Option: -t

Required: Yes, when using `hardupdate` or `update` modes

Should be a full file address to a PHP file which will be used as the template for the PHP files that will be created

### Config Name
Option: -c

Required: No, defaults to `sitemd_conf`

The name of the root config file, .json can be included at the end or not, it will make no difference.

### Recursive
Option: -r

Required: No

If included, the script will update or clear recursively through all PHP files in all directories within the root directory.

## Setup

Download the script, root config file and example template from this github page. Place these within an empty directory within your root website directory. This directory is the root sitemd directory. Within this directory and within other directories within the root sitemd directory you can add markdown files (`.md`). Each markdown file is a single webpage within the site.

Each time a new markdown file is created, run `./sitemd -m update -t <template> -r` to create the new php files.

Each time you make changes to the template, run `./sitemd -m hardupdate -t <template> -r` to recreate all php files using the updated template.

### Example Setup Prior To Running `sitemd.sh`
`- /html`

`....|- /html/md`

`........|- /html/md/sitemd.sh`

`........|- /html/md/sitemd_conf.json`

`........|- /html/md/template.php`

`........|- /html/md/project1.md`

`........|- /html/md/project1`

`............|- /html/md/project1/doc1.md`

`............|- /html/md/project1/doc2.md`
### Example Setup After Running `sitemd.sh`
`- /html`

`....|- /html/md`

`........|- /html/md/sitemd.sh`

`........|- /html/md/sitemd_conf.json`

`........|- /html/md/sitemd_dir.json`

`........|- /html/md/template.php`

`........|- /html/md/project1.md`

`........|- /html/md/project1.php`

`........|- /html/md/project1`

`............|- /html/md/project1/sitemd_dir.json`

`............|- /html/md/project1/doc1.md`

`............|- /html/md/project1/doc1.php`

`............|- /html/md/project1/doc2.md`

`............|- /html/md/project1/doc2.php`
