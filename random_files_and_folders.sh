#!/bin/bash
# Checks if this script is already running, if it's running write an error and exit
# creates 100 random folders
# creates 100 files in each folder with the following rules:
# - random size of 50K to 200K
# - random file-name prefix of a, b or c
# - random content of a-z, A-Z, 0-9, ' ' (space)
# for each file in each folder, remove all spaces in a file
# for each file in each folder, create .md5 file
# if any of the steps above fails, exit and write an email

### CHECK IF SCRIPT IS ALREADY RUNNING
status=`ps -efww | grep -w "$0" | grep -v grep | grep -v $$ | awk '{ print $2 }'`
if [ ! -z "$status" ]; then
        echo "[`date`] : $0 : Process is already running"
        exit 1;
fi

function finish {
        USER_EMAIL=user@email.com
        echo "Subject: $0 script has exited abnormaly, please check" | /usr/sbin/sendmail -v $USER_EMAIL
        echo "something bad happened or script finished..."
        exit 1
}
## Trap our soul in memory in case script does gets killed, so we can send last email to alert admin
trap finish ERR INT TERM

function generate_files {
mkdir -p folders && cd folders
for i in {1..100};do
        RANDOM_FOLDER=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
        mkdir $RANDOM_FOLDER
        for x in {1..100};do
                FILE_SIZE=$(shuf -i 50-200 -n 1)
                FILE_PREFIX_CHAR=$(var="abc" && echo "${var:$(( RANDOM % ${#var} )):1}")
                cat  /dev/urandom | tr -cd "[a-z][A-Z][0-9][:space:]" | head -c "${FILE_SIZE}"KB > "${RANDOM_FOLDER}"/"${FILE_PREFIX_CHAR}"_$x.file
        done
done
}

## clean spaces from files
function clean_spaces {
        ## run over all files in folders dir and clean "space"  characters
        find folders/ -type f -exec sed -i 's/[[:space:]]//g' {} \;
}
## create .md5 file for each file in each folder
function create_md5 {
        ## run over all files in folders dir and create md5 file
        find folders/ ! -name '*.md5' -type f -exec sh -c "md5sum {} > {}.md5" \;
}


generate_files || finish
cd ~
du -s folders  ## Show size of folders before spaces clean
clean_spaces   || finish
du -s folders  ## Show size of folders after spaces clean
create_md5     || finish