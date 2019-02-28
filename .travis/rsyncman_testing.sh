#!/bin/bash

mkdir -p /var/log/rsyncman

sed "s#@@PWD@@#$(pwd)#g" -i $(pwd)/.travis/*.config

for i in $(pwd)/.travis/*.config
do
  echo "== $i =="
  cat $i
  echo ""
done

if [ ! -f "$(pwd)/files/rsyncman.py" ];
then
  echo "rsyncman.py NOT FOUND - ABORTING"
  exit 1
fi

echo "###############################################"
echo "################ BEGIN TESTING ################"
echo "###############################################"

DIR_ORIGIN="$(pwd)/.travis/origin"
DIR_DESTINATION="$(pwd)/.travis/destination"

pip install -r "$(pwd)/files/requirements.txt"

echo "==================="
echo "* 0 - BASE STATUS *"
echo "==================="

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

echo "=============="
echo "* 1 - DRYRUN *"
echo "=============="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config -d

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

echo "============="
echo "* 2 - RSYNC *"
echo "============="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config

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

echo "========================="
echo "* 3 - SYNC BACK DRY RUN *"
echo "========================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config -b -d

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_to_be_removed" ];
then
  TEST3_1="ok"
fi

if [ ! -f "${DIR_ORIGIN}/file_to_be_copied_back" ];
then
  TEST3_2="ok"
fi

if [ -f "${DIR_ORIGIN}/.snapshot" ];
then
  TEST3_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/.snapshot" ];
then
  TEST3_4="ok"
fi

echo "================="
echo "* 4 - SYNC BACK *"
echo "================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config -b

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

# check file is not being transfered
touch "${DIR_ORIGIN}/file_not_to_be_copied"

echo "==========================="
echo "* 5 - WRONG LOCAL FSTYPE  *"
echo "==========================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-local-wrong-fs.config

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST5_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST5_2="ok"
fi

echo "====================================="
echo "* 5b - WRONG LOCAL FSTYPE SYNC BACK *"
echo "====================================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-local-wrong-fs.config -b

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST5_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST5_4="ok"
fi

echo "==========================="
echo "* 6 - WRONG REMOTE FSTYPE *"
echo "==========================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-remote-wrong-fs.config

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST6_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST6_2="ok"
fi

echo "======================================"
echo "* 6b - WRONG REMOTE FSTYPE SYNC BACK *"
echo "======================================"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-remote-wrong-fs.config -b

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST6_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST6_4="ok"
fi

echo "========================="
echo "* 7 - CHECKFILE FAILURE *"
echo "========================="

rm -f "${DIR_ORIGIN}/check_file"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST7_1="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST7_2="ok"
fi

echo "===================================="
echo "* 7b - CHECKFILE FAILURE SYNC BACK *"
echo "===================================="

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync.config -b

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/file_not_to_be_copied" ];
then
  TEST7_3="ok"
fi

if [ ! -f "${DIR_DESTINATION}/file_not_to_be_copied" ];
then
  TEST7_4="ok"
fi

echo "==================="
echo "* 8 - CANARY FILE *"
echo "==================="

touch "${DIR_ORIGIN}/canary_copy"
touch "${DIR_ORIGIN}/check_file"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-canary.config

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/canary_copy" ];
then
  TEST8_1="ok"
fi

if [ -f "${DIR_DESTINATION}/canary_copy" ];
then
  TEST8_2="ok"
fi

if [ -s "${DIR_ORIGIN}/canaryfile" ];
then
  TEST8_3="ok"
fi

if [ -s "${DIR_DESTINATION}/canaryfile" ];
then
  TEST8_4="ok"
fi

echo "============================="
echo "* 9 - CANARY FILE SYNC BACK *"
echo "============================="

touch "${DIR_DESTINATION}/canary_syncback_copy"
touch "${DIR_ORIGIN}/check_file"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-canary-syncback.config -b

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/canary_syncback_copy" ];
then
  TEST9_1="ok"
fi

if [ -f "${DIR_DESTINATION}/canary_syncback_copy" ];
then
  TEST9_2="ok"
fi

if [ -s "${DIR_ORIGIN}/canaryfile_syncback" ];
then
  TEST9_3="ok"
fi

if [ -s "${DIR_DESTINATION}/canaryfile_syncback" ];
then
  TEST9_4="ok"
fi

echo "======================"
echo "* 10 - CANARY STRING *"
echo "======================"

touch "${DIR_ORIGIN}/canary_string_copy"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-canary.config -S ACCEPTANCE

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/canary_string_copy" ];
then
  TEST10_1="ok"
fi

if [ -f "${DIR_DESTINATION}/canary_string_copy" ];
then
  TEST10_2="ok"
fi

if [ -s "${DIR_ORIGIN}/canaryfile" ];
then
  TEST10_3="ok"
fi

if [ -s "${DIR_DESTINATION}/canaryfile" ];
then
  TEST10_4="ok"
fi

grep ACCEPTANCE "${DIR_ORIGIN}/canaryfile"

if [ "$?" -eq 0 ];
then
  TEST10_5="ok"
fi

grep ACCEPTANCE "${DIR_DESTINATION}/canaryfile"

if [ "$?" -eq 0 ];
then
  TEST10_6="ok"
fi

echo "=============================="
echo "* 11 - CANARY FILE SYNC BACK *"
echo "=============================="

touch "${DIR_DESTINATION}/canary_string_syncback_copy"
touch "${DIR_ORIGIN}/check_file"

python $(pwd)/files/rsyncman.py -c $(pwd)/.travis/localrsync-canary-syncback.config -b -S ACCEPTANCE

echo $DIR_ORIGIN
ls -la $DIR_ORIGIN

echo $DIR_DESTINATION
ls -la $DIR_DESTINATION

if [ -f "${DIR_ORIGIN}/canary_string_syncback_copy" ];
then
  TEST11_1="ok"
fi

if [ -f "${DIR_DESTINATION}/canary_string_syncback_copy" ];
then
  TEST11_2="ok"
fi

if [ -s "${DIR_ORIGIN}/canaryfile_syncback" ];
then
  TEST11_3="ok"
fi

if [ -s "${DIR_DESTINATION}/canaryfile_syncback" ];
then
  TEST11_4="ok"
fi

grep ACCEPTANCE "${DIR_ORIGIN}/canaryfile_syncback"

if [ "$?" -eq 0 ];
then
  TEST11_5="ok"
fi

grep ACCEPTANCE "${DIR_DESTINATION}/canaryfile_syncback"

if [ "$?" -eq 0 ];
then
  TEST11_6="ok"
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
echo "TEST5_3: ${TEST5_3}"
echo "TEST5_4: ${TEST5_4}"
echo ""
echo "TEST 6 - wrong remote fs type"
echo "======"
echo "TEST6_1: ${TEST6_1}"
echo "TEST6_2: ${TEST6_2}"
echo "TEST6_3: ${TEST6_3}"
echo "TEST6_4: ${TEST6_4}"
echo ""
echo "TEST 7 - checkfile failure"
echo "======"
echo "TEST7_1: ${TEST7_1}"
echo "TEST7_2: ${TEST7_2}"
echo "TEST7_3: ${TEST7_3}"
echo "TEST7_4: ${TEST7_4}"
echo ""
echo "TEST 8 - canary file"
echo "======"
echo "TEST8_1: ${TEST8_1}"
echo "TEST8_2: ${TEST8_2}"
echo "TEST8_3: ${TEST8_3}"
echo "TEST8_4: ${TEST8_4}"
echo ""
echo "TEST 9 - canary file sync back"
echo "======"
echo "TEST9_1: ${TEST9_1}"
echo "TEST9_2: ${TEST9_2}"
echo "TEST9_3: ${TEST9_3}"
echo "TEST9_4: ${TEST9_4}"
echo ""
echo "TEST 10 - canary string"
echo "======"
echo "TEST10_1: ${TEST10_1}"
echo "TEST10_2: ${TEST10_2}"
echo "TEST10_3: ${TEST10_3}"
echo "TEST10_4: ${TEST10_4}"
echo "TEST10_5: ${TEST10_5}"
echo "TEST10_6: ${TEST10_5}"
echo ""
echo "TEST 11 - canary string sync back"
echo "======"
echo "TEST11_1: ${TEST11_1}"
echo "TEST11_2: ${TEST11_2}"
echo "TEST11_3: ${TEST11_3}"
echo "TEST11_4: ${TEST11_4}"
echo "TEST11_5: ${TEST11_5}"
echo "TEST11_6: ${TEST11_6}"

echo ""
echo "****************************************************************************"
echo ""

if [ -z "${TEST0_1}" ] || [ -z "${TEST0_2}" ] || [ -z "${TEST0_3}" ] || [ -z "${TEST0_4}" ] || \
    [ -z "${TEST1_1}" ] || [ -z "${TEST1_2}" ] || [ -z "${TEST1_3}" ] || [ -z "${TEST1_4}" ] || \
    [ -z "${TEST2_1}" ] || [ -z "${TEST2_2}" ] || [ -z "${TEST2_3}" ] || [ -z "${TEST2_4}" ] || \
    [ -z "${TEST3_1}" ] || [ -z "${TEST3_2}" ] || [ -z "${TEST3_3}" ] || [ -z "${TEST3_4}" ] || \
    [ -z "${TEST4_1}" ] || [ -z "${TEST4_2}" ] || [ -z "${TEST4_3}" ] || [ -z "${TEST4_4}" ] || \
    [ -z "${TEST5_1}" ] || [ -z "${TEST5_2}" ] || [ -z "${TEST5_3}" ] || [ -z "${TEST5_4}" ] || \
    [ -z "${TEST6_1}" ] || [ -z "${TEST6_2}" ] || [ -z "${TEST6_3}" ] || [ -z "${TEST6_4}" ] || \
    [ -z "${TEST7_1}" ] || [ -z "${TEST7_2}" ] || [ -z "${TEST7_3}" ] || [ -z "${TEST7_4}" ] || \
    [ -z "${TEST8_1}" ] || [ -z "${TEST8_2}" ] || [ -z "${TEST8_3}" ] || [ -z "${TEST8_4}" ] || \
    [ -z "${TEST9_1}" ] || [ -z "${TEST9_2}" ] || [ -z "${TEST9_3}" ] || [ -z "${TEST9_4}" ] || \
    [ -z "${TEST10_1}" ] || [ -z "${TEST10_2}" ] || [ -z "${TEST10_3}" ] || [ -z "${TEST10_4}" ] || [ -z "${TEST10_5}" ] || [ -z "${TEST10_6}" ] || \
    [ -z "${TEST11_1}" ] || [ -z "${TEST11_2}" ] || [ -z "${TEST11_3}" ] || [ -z "${TEST11_4}" ] || [ -z "${TEST11_5}" ] || [ -z "${TEST11_6}" ];
then
  echo "ERRORS FOUND"
  echo ""
  exit 1
else
  cat <<EOF
  ▄▄█████████████████████████████─
  ▀▀▀───▀█▄▀▄▀████▀──▀█▄▀▄▀████▀──
  ────────▀█▄█▄█▀──────▀█▄█▄█▀────

              TESTING OK
EOF
  echo ""
  exit 0
fi
