# rsync

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What rsync affects](#what-rsync-affects)
    * [Beginning with rsync](#beginning-with-rsync)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
    * [TODO](#todo)
    * [Contributing](#contributing)

## Overview

rsync and rsyncman job management

## Module Description

This module can schedule ryncs and rsyncman jobs to be able to syncronize data

## Setup

### What rsync affects

* Manages rsync package
* Installs rsyncman via **rsync::manager**
* Creates cronjobs for rsync amb rsyncman

### Beginning with rsync

#### rsync

Configure a rsync job everyday at 0:00 to copy data from /origin to /destination on the same server

```puppet
rsync::scheduledrsync { 'demo':
  origin      => '/origin',
  destination => '/destination',
  hour    => '0',
  minute  => '0',
}
```

#### rsyncman

Configure a rsync job everyday at 0:00 to copy data from /demo to testuser@1.2.3.4:/demo2, sending a report to demo@example.com

```puppet
rsync::manager::schedule { 'demo':
  mail_to => 'demo@example.com',
  host_id => 'demopuppet',
  hour    => '0',
  minute  => '0',
}

rsync::manager::job { 'demo':
  path        => '/demo',
  remote      => 'testuser@1.2.3.4',
  remote_path => '/demo2',
}
```

## Usage

### rsyncman usage

```
Usage: rsyncman.py [-c <config file>] [-b]

-h,--help: print this message
-c,--config: config file
-b,--syncback: sync from destination to origin
-d,--dryrun: dry run - just simulate execution
-S,--canarystring: canary string
```

## Reference

### rsync

* **manage_package**: (default: true)
* **package_ensure**: (default: installed)

#### rsync::scheduledrsync

* **origin**:,
* **destination**:,
* **ensure**:          = 'present',
* **cronjobname**:     = undef,
* **user**:            = 'root',
* **ionice**:          = true,
* **ionice_class**:    = '2',
* **ionice_level**:    = '2',
* **delete**:          = true,
* **hour**:            = '\*',
* **minute**:          = '\*',
* **month**:           = '\*',
* **monthday**:        = '\*',
* **weekday**:         = '\*',
* **archive**:         = true,
* **hardlinks**:       = true,
* **one_file_system**: = true,
* **chmod**:           = undef,

### rsync::manager

Default configuation file for rsyncman is expected to be ./rsyncman.config, but can be used a different file using the -c option

#### config options

Configuration file will habe a global config section (rsyncman) and as many path as needed

##### rsyncman section

Global config section

* logdir
* to
* host-id

##### job section

Job specific options (can be configured more than one job) Section name is the local path

* ionice
* rsync-path
* exclude
* delete
* remote
* remote-path
* check-file
* canary-file
* expected-fs
* expected-remote-fs

##### example config file

```
[rsyncman]
to=demo@example.com
host-id=DEMOHOST1234
logdir=/var/log/rsyncman.log

[/test_rsync]
ionice="-c2 -n2"
rsync-path="sudo rsync"
exclude = [ "exclude1","exclude2" ]
delete = false
remote="jprats@127.0.0.1"
remote-path="/test_rsync"
check-file=is.mounted
expected-fs=nfs
expected-remote-fs=nfs
```


#### rsync::manager::schedule

* **ensure**:        = 'present',
* **schedule_name**: = $name,
* **user**:          = 'root',
* **hour**:          = '\*',
* **minute**:        = '\*',
* **month**:         = '\*',
* **monthday**:      = '\*',
* **weekday**:       = '\*',
* **mail_to**:       = undef,
* **host_id**:       = undef,
* **logdir**:        = '/var/log/rsyncman',

#### rsync::manager::job

* **path**:,
* **remote**:,
* **remote_path**:        = undef,
* **schedule_name**:      = $name,
* **ionice_args**:        = undef,
* **rsync_path**:         = undef,
* **exclude**:            = [],
* **delete**:             = false,
* **check_file**:         = undef,
* **expected_fs**:        = undef,
* **expected_remote_fs**: = undef,
* **order**:              = '42',

## Limitations

Tested on CentOS and on Ubuntu but should work anywhere

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
