#!/bin/bash
usage() { echo "Usage: $0 [-m <'update' | 'hardupdate' | 'clear'>] [-t </template/file/location.php>] [-c <root config filename, default='sitemd_conf'>] [-r]"; exit 1;}

RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NOCOl='\033[0m'

CURDIR=`pwd`

# check jq installed
if ! type "jq" > /dev/null; then
    echo -e "${RED}ERROR: jq not found, try installing jq with 'apt install jq'${NOCOl}"
    exit 1
fi

# get options
rflag=0
mflag=0
tflag=0
configname="sitemd_conf"
while getopts :m:t::rc:: flag
do
    case "${flag}" in
        t)  template=${OPTARG}
            tflag=1
            ;;

        m)  mode=${OPTARG}
            mflag=1
            ;;

        r)  rflag=1
            ;;
        c)  configname=${OPTARG}
            ;;

        \?) echo -e "${RED}An invalid option has been entered: $OPTARG${NOCOl}"
            usage
            ;;

        :)  echo -e "${RED}The required argument was omitted for the option: $OPTARG${NOCOl}"
            usage
            ;;
    esac
done

# check required options are present
if [[ $mflag -eq 0 ]]; then
    echo -e "${RED}The required option was omitted: m${NOCOl}"
    usage
fi

# read root config file
if [[ ${configname: -5} != ".json" ]]; then
    conffile=$dir$configname".json"
else
    conffile=$dir$configname
fi

if [[ -f $conffile ]]; then
    echo -e "${BLUE}CONFIG: $conffile${NOCOl}"

    # filename for directory config files
    hasDirConfigName=`cat $conffile | jq 'has("dir_config")'`
    if [[ "$hasDirConfigName" = "true" ]]; then
        dirConfigName=`cat $conffile | jq '.dir_config'`
        # strip quotes from start and finish
        dirConfigName="${dirConfigName%\"}"
        dirConfigName="${dirConfigName#\"}"
    else
        dirConfigName="sitemd_dir"
    fi
else
    echo -e "${RED}No root config file found at: $conffile${NOCOl}"
    echo -e "${RED}Either create a root config file or use the -c option to choose a custom root config filename.${NOCOl}"
    exit
fi

require_tflag() {
    # check required options are present
    if [[ $tflag -eq 0 ]]; then
        echo -e "${RED}The required option was omitted: t${NOCOl}"
        usage
    fi

    # check template is a .php file
    if [[ ${template: -4} != ".php" ]]; then
        echo -e "${RED}The template file given is not of type .php${NOCOl}"
        usage
    fi

    # check template file exists
    if [[ ! -f "$template" ]]; then
        echo -e "${RED}The template file given does not exist${NOCOl}"
        usage
    fi
}

# functions
getMDFiles() {
    if [[ $rflag -eq 1 ]]; then
            echo "SETUP: Searching for markdown files recursively"
            FILES=`find $CURDIR -name "*.md"`
    else
            echo "SETUP: Searching for markdown files in this directory"
            FILES="$CURDIR/*.md"
    fi

    for f in $FILES
    do
        echo -e "${BLUE}FOUND: $f${NOCOl}"
    done
}

findConfig() {
    if [[ ${dirConfigName: -5} != ".json" ]]; then
        conffile=$dir$dirConfigName".json"
    else
        conffile=$dir$dirConfigName
    fi
    
    if [[ -f $conffile ]]; then
        echo -e "${BLUE}CONFIG: $conffile FOR $newphpfile${NOCOl}"
    else
        echo -e "${BLUE}NO CONFIG: None found AT $conffile"
        # create a new dir config file with root dir already included
        jq --null-input --arg root "$CURDIR" '{"root_dir": $root}' > $conffile
        echo -e "${BLUE}CREATED CONFIG: $conffile FOR $newphpfile${NOCOl}"
    fi
}

# run command
if [[ "$mode" = "update" ]]; then
    require_tflag

    # get markdown files
    getMDFiles

    # create php files from template
    echo "SETUP: Creating PHP files from template"

    for f in $FILES
    do
        dir=`dirname $f`"/"
        filename=`basename $f .md`
        php=".php"
        newphpfile=$dir$filename$php

        # look for config json file
        findConfig

        # create php file
        if [[ ! -f "$newphpfile" ]]; then
            cp $template $newphpfile
            echo -e "${BLUE}CREATED: $newphpfile${NOCOl}"
        else
            echo -e "${BLUE}EXISTS: $newphpfile${NOCOl}"
        fi
    done

    echo "COMPLETE: All required files created"

elif [[ "$mode" = "hardupdate" ]]; then
    require_tflag

    # check user wants to continue
    echo -e "${YELLOW}WARNING: This will delete all site.md php files and recreate them from the given template.\nAre you sure you want to continue (y/n):${NOCOl}"
    read userval

    if [[ ! $userval = "y" ]]; then
        echo "Stopping..."
        exit 0
    fi

    # get markdown files
    getMDFiles

    # create php files from template
    echo "SETUP: Creating PHP files from template"

    for f in $FILES
    do
        dir=`dirname $f`"/"
        filename=`basename $f .md`
        php=".php"
        newphpfile=$dir$filename$php

        # look for config json file
        findConfig

        # create php file
        if [[ ! -f "$newphpfile" ]]; then
            cp $template $newphpfile
            echo -e "${BLUE}CREATED: $newphpfile${NOCOl}"
        else
            rm $newphpfile
            echo -e "${BLUE}DELETED: $newphpfile${NOCOl}"
            cp $template $newphpfile
            echo -e "${BLUE}CREATED: $newphpfile${NOCOl}"
        fi
    done

    echo "COMPLETE: All files created"
elif [[ "$mode" = "clear" ]]; then
    # check user wants to continue
    echo -e "${YELLOW}WARNING: This will delete all site.md php files.\nAre you sure you want to continue (y/n):${NOCOl}"
    read userval

    if [[ ! $userval = "y" ]]; then
        echo "Stopping..."
        exit 0
    fi

    # get markdown files
    getMDFiles

    # remove php files from
    echo "SETUP: Removing PHP files"

    for f in $FILES
    do
        dir=`dirname $f`"/"
        filename=`basename $f .md`
        php=".php"
        newphpfile=$dir$filename$php
        if [[ ! -f "$newphpfile" ]]; then
            echo -e "${BLUE}NOFILE: $newphpfile${NOCOl}"
        else
            rm $newphpfile
            echo -e "${BLUE}DELETED: $newphpfile${NOCOl}"
        fi
    done

    echo "COMPLETE: All files deleted"
else
    usage
fi

exit 0
