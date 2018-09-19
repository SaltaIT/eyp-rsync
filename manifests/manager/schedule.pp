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
  cron { $schedule_name:
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

  # DEBUG
  # file { '/tmp/rsync':
  #   ensure => 'present',
  #   content => template("${module_name}/rsync.erb"),
  # }

}
