#!/bin/bash

# pwd
# /home/travis/build/jordiprats/eyp-rsync

mkdir -p /var/log/rsyncman

DIR_ORIGIN="/home/travis/build/jordiprats/eyp-rsync/.travis/origin"
DIR_DESTINATION="/home/travis/build/jordiprats/eyp-rsync/.travis/destination"

pip install -r /home/travis/build/jordiprats/eyp-rsync/files/requirements.txt

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f ]

exit 0
