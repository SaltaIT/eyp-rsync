define rsync::manager::schedule (
                                  $ensure        = 'present',
                                  $schedule_name = $name,
                                  $user          = 'root',
                                  $hour          = '*',
                                  $minute        = '*',
                                  $month         = '*',
                                  $monthday      = '*',
                                  $weekday       = '*',
                                  $mail_to       = undef,
                                  $host_id       = undef,
                                  $logdir        = '/var/log/rsyncman',
                                ) {
  include ::rsync::manager

  cron { $schedule_name:
    ensure   => $ensure,
    command  => "/usr/bin/rsyncman -c /etc/rsyncman/${schedule_name}.conf\n",
    user     => $user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
  }

  concat { "/etc/rsyncman/${schedule_name}.conf":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0640',
  }

  concat::fragment{ "/etc/rsyncman/${schedule_name}.conf global config":
    target  => "/etc/rsyncman/${schedule_name}.conf",
    order   => '00',
    content => template("${module_name}/rsyncman/base.erb")
  }

}
