define rsync::scheduledrsync(
                              $origin,
                              $destination,
                              $ensure          = 'present',
                              $cronjobname     = undef,
                              $user            = 'root',
                              $ionice          = true,
                              $ionice_class    = '2',
                              $ionice_level    = '2',
                              $delete          = true,
                              $hour            = '*',
                              $minute          = '*',
                              $month           = '*',
                              $monthday        = '*',
                              $weekday         = '*',
                              $archive         = true,
                              $hardlinks       = true,
                              $one_file_system = true,
                              $chmod           = undef,
                            ) {

  if($cronjobname!=undef)
  {
    $cron_job_name=$cronjobname
  }
  else
  {
    $cron_job_name="cronjob rsync ${name}"
  }

  #command  => inline_template('<% if @ionice %>ionice -c2 -n2 <% end %>rsync -a -H -x --numeric-ids <% if @delete %>--delete <% end %><%= @origin %> <%= @destination %>'),
  cron { $cron_job_name:
    ensure   => $ensure,
    command  => template("${module_name}/rsync.erb"),
    user     => $user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
  }

  # DEBUG
  # file { '/tmp/rsync':
  #   ensure => 'present',
  #   content => template("${module_name}/rsync.erb"),
  # }

}
