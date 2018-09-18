define rsync::manager::schedule (
                                  $ensure        = 'present',
                                  $schedule_name = $name,
                                  $hour          = '*',
                                  $minute        = '*',
                                  $month         = '*',
                                  $monthday      = '*',
                                  $weekday       = '*',
                                  $mail_to       = undef,
                                  $host_id       = undef,
                                ) {
  include ::rsync::manager

  #command  => inline_template('<% if @ionice %>ionice -c2 -n2 <% end %>rsync -a -H -x --numeric-ids <% if @delete %>--delete <% end %><%= @origin %> <%= @destination %>'),
  cron { $cron_job_name:
    ensure   => $ensure,
    command  => "/usr/bin/rsyncman /etc/rsyncman/${schedule_name}.conf\n",
    user     => $user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
  }

  concat { "/etc/rsyncman/${schedule_name}.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
  }

  concat::fragment{ "/etc/mysql/${instance_name}/my.cnf header":
    target  => "/etc/mysql/${instance_name}/my.cnf",
    order   => '000',
    content => "#\n# puppet managed file\n#\n\n",
  }

  # DEBUG
  # file { '/tmp/rsync':
  #   ensure => 'present',
  #   content => template("${module_name}/rsync.erb"),
  # }

}
