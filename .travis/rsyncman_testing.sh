#!/bin/bash

# pwd
# /home/travis/build/jordiprats/eyp-rsync

mkdir -p /var/log/rsyncman

DIR_ORIGIN="/home/travis/build/jordiprats/eyp-rsync/.travis/origin"
DIR_DESTINATION="/home/travis/build/jordiprats/eyp-rsync/.travis/destination"

pip install -r /home/travis/build/jordiprats/eyp-rsync/files/requirements.txt

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ ! -f "${DIR_DESTINATION}/file_to_be_copied" ];
then
  TEST0_1="ok"
fi

if [ -f "${DIR_DESTINATION}/file_to_be_deleted" ];
then
  TEST0_2="ok"
fi

echo ""
echo "TEST 0 - check environment"
echo "======"
echo "TEST0_1: ${TEST0_1}"
echo "TEST0_2: ${TEST0_2}"
echo ""

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config

if [ -f "${DIR_DESTINATION}/file_to_be_copied" ];
then
  TEST1_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_to_be_deleted" ];
then
  TEST1_2="ok"
fi

echo ""
echo "TEST 1 - after running rsync"
echo "======"
echo "TEST1_1: ${TEST1_1}"
echo "TEST1_2: ${TEST1_2}"
echo ""

if [ -z "${TEST0_1}" ] || [ -z "${TEST0_2}" ] || [ -z "${TEST1_1}" ] || [ -z "${TEST1_2}" ];
then
  echo "FOUND ERRORS"
  exit 1
else
  echo "TESTING OK"
  exit 0
fi
