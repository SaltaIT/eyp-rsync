# CHANGELOG

## 0.1.12

* rsyncman: fix dependencies **rsync::manager::job**

## 0.1.11

* **rsyncman**:
  - added exclude-from
  - added default-reverse flag
  - added compress flag
  - added pre and post execution scripts

## 0.1.10

* **rsyncman**:
  * added dryrun option
  * allow local destinations (ie remote is an empty string)
  * added support for canary-file
  * added flag to be able to configure a canary string to be written in the canary-file
  * added acceptance testing for rsyncman

## 0.1.9

* rsyncman: fix dependencies

## 0.1.8

* minor bugfix rsyncman

## 0.1.7

* rsyncman.py bugfix:
  - NFS mounts were not detected correctly as shares
  - fix remote fs type detection

## 0.1.6

* rsyncman.py bugfix
* configurable owner, group and mode for schedules config files
* configurable file mode for log directory

## 0.1.5

* added rsyncmanager
* added support for Ubuntu 16.04 and 18.04

## 0.1.4

* added chmod option to rsync
* added variables for some hard coded rsync options:
  * archive
  * hardlinks
  * one_file_system
* added configurable ionice class and level

## 0.1.3

* added delete option

## 0.1.2

* removed default values for cronjob
* bugfix rsync

## 0.1.0

* initial release
