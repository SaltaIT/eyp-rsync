define rsync::scheduledrsync(
                              $origin,
                              $destination,
                              $ensure      = 'present',
                              $cronjobname = undef,
                              $user        = 'root',
                              $ionice      = true,
                              $delete      = true,
                              $hour        = undef,
                              $minute      = undef,
                              $month       = undef,
                              $monthday    = undef,
                              $weekday     = undef,
                            ) {

  if($cronjobname!=undef)
  {
    $cron_job_name=$cronjobname
  }
  else
  {
    $cron_job_name="cronjob rsync ${name}"
  }

  #"find ${path} ${type} -mtime ${mtime} ${action}"
  cron { $cron_job_name:
    ensure   => $ensure,
    command  => inline_template('<% if @ionice %>ionice -c2 -n2 <% end %>rsync -a -H -x --numeric-ids <% if @delete %>--delete <% end %><%= @origin %> <%= @destination %>'),
    user     => $user,
    hour     => $hour,
    minute   => $minute,
    month    => $month,
    monthday => $monthday,
    weekday  => $weekday,
  }

}
