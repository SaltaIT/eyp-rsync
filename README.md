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

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

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
