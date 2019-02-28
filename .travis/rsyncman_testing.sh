#!/bin/bash

# pwd
# /home/travis/build/jordiprats/eyp-rsync

mkdir -p /var/log/rsyncman

DIR_ORIGIN="/home/travis/build/jordiprats/eyp-rsync/.travis/origin"
DIR_DESTINATION="/home/travis/build/jordiprats/eyp-rsync/.travis/destination"

pip install -r /home/travis/build/jordiprats/eyp-rsync/files/requirements.txt

echo "==============="
echo "* BASE STATUS *"
echo "==============="

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ ! -f "${DIR_DESTINATION}/file_to_be_copied" ];
then
  TEST0_1="ok"
fi

if [ -f "${DIR_DESTINATION}/file_to_be_removed" ];
then
  TEST0_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST0_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST0_4="ok"
fi

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config -d

echo "================"
echo "* AFTER DRYRUN *"
echo "================"

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ ! -f "${DIR_DESTINATION}/file_to_be_copied" ];
then
  TEST1_1="ok"
fi

if [ -f "${DIR_DESTINATION}/file_to_be_removed" ];
then
  TEST1_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST1_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST1_4="ok"
fi

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config

echo "==============="
echo "* AFTER RSYNC *"
echo "==============="

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_DESTINATION}/file_to_be_copied" ];
then
  TEST2_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_to_be_removed" ];
then
  TEST2_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST2_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST2_4="ok"
fi

touch "${DIR_DESTINATION}/file_to_be_copied_back"
touch "${DIR_ORIGIN}/file_to_be_removed"

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config -b -d

echo "====================="
echo "* SYNC BACK DRY RUN *"
echo "====================="

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_to_be_removed" ];
then
  TEST4_1="ok"
fi

if [ ! -f "${DIR_ORIGIN}/file_to_be_copied_back" ];
then
  TEST4_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST4_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST4_4="ok"
fi

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config -b

echo "============="
echo "* SYNC BACK *"
echo "============="

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ ! -f "${DIR_ORIGIN}/file_to_be_removed" ];
then
  TEST4_1="ok"
fi

if [ -f "${DIR_ORIGIN}/file_to_be_copied_back" ];
then
  TEST4_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST4_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST4_4="ok"
fi

touch "${DIR_ORIGIN}/file_not_to_be_copied"

echo "======================="
echo "* WRONG LOCAL FSTYPE  *"
echo "======================="

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync-local-wrong-fs.config

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST5_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST5_2="ok"
fi

echo "========================"
echo "* WRONG REMOTE FSTYPE  *"
echo "========================"

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync-remote-wrong-fs.config

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST6_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST6_2="ok"
fi

echo "====================="
echo "* CHECKFILE FAILURE *"
echo "====================="

rm -f "${DIR_ORIGIN}/check_file"

python /home/travis/build/jordiprats/eyp-rsync/files/rsyncman.py -c /home/travis/build/jordiprats/eyp-rsync/.travis/localrsync.config

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST7_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST7_2="ok"
fi

echo ""
echo "TEST 0 - check environment"
echo "======"
echo "TEST0_1: ${TEST0_1}"
echo "TEST0_2: ${TEST0_2}"
echo "TEST0_3: ${TEST0_3}"
echo "TEST0_4: ${TEST0_4}"
echo ""
echo "TEST 1 - dry run"
echo "======"
echo "TEST1_1: ${TEST1_1}"
echo "TEST1_2: ${TEST1_2}"
echo "TEST1_3: ${TEST1_3}"
echo "TEST1_4: ${TEST1_4}"
echo ""
echo "TEST 2 - after running rsync"
echo "======"
echo "TEST2_1: ${TEST2_1}"
echo "TEST2_2: ${TEST2_2}"
echo "TEST2_3: ${TEST2_3}"
echo "TEST2_4: ${TEST2_4}"
echo ""
echo "TEST 3 - sync back dry run"
echo "======"
echo "TEST3_1: ${TEST3_1}"
echo "TEST3_2: ${TEST3_2}"
echo "TEST3_3: ${TEST3_3}"
echo "TEST3_4: ${TEST3_4}"
echo ""
echo "TEST 4 - sync back"
echo "======"
echo "TEST4_1: ${TEST4_1}"
echo "TEST4_2: ${TEST4_2}"
echo "TEST4_3: ${TEST4_3}"
echo "TEST4_4: ${TEST4_4}"
echo ""
echo "TEST 5 - wrong local fs type"
echo "======"
echo "TEST5_1: ${TEST5_1}"
echo "TEST5_2: ${TEST5_2}"
echo ""
echo "TEST 5 - wrong remote fs type"
echo "======"
echo "TEST6_1: ${TEST6_1}"
echo "TEST6_2: ${TEST6_2}"
echo ""
echo "TEST 7 - checkfile failure"
echo "======"
echo "TEST7_1: ${TEST7_1}"
echo "TEST7_2: ${TEST7_2}"
echo ""

if [ -z "${TEST0_1}" ] || [ -z "${TEST0_2}" ] || [ -z "${TEST0_3}" ] || [ -z "${TEST0_4}" ] || \
    [ -z "${TEST1_1}" ] || [ -z "${TEST1_2}" ] || [ -z "${TEST1_3}" ] || [ -z "${TEST1_4}" ] || \
    [ -z "${TEST2_1}" ] || [ -z "${TEST2_2}" ] || [ -z "${TEST2_3}" ] || [ -z "${TEST2_4}" ] || \
    [ -z "${TEST3_1}" ] || [ -z "${TEST3_2}" ] || [ -z "${TEST3_3}" ] || [ -z "${TEST3_4}" ] || \
    [ -z "${TEST4_1}" ] || [ -z "${TEST4_2}" ] || [ -z "${TEST4_3}" ] || [ -z "${TEST4_4}" ] || \
    [ -z "${TEST5_1}" ] || [ -z "${TEST5_2}" ] || \
    [ -z "${TEST6_1}" ] || [ -z "${TEST6_2}" ] || \
    [ -z "${TEST7_1}" ] || [ -z "${TEST7_2}" ];
then
  echo "FOUND ERRORS"
  exit 1
else
  echo "TESTING OK"
  exit 0
fi
