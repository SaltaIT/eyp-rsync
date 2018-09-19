class rsync::manager::install inherits rsync::manager {

  package { $rsync::params::rsyncman_dependencies:
    ensure => 'installed',
  }

  file { '/usr/bin/rsyncman':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => file("${module_name}/rsyncman.py"),
    require => Package[$rsync::params::rsyncman_dependencies],
  }

  file { '/etc/rsyncman':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { '/var/log/rsyncman':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }
}
