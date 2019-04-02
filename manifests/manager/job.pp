define rsync::manager::job(
                            $path,
                            $remote,
                            $remote_path        = undef,
                            $schedule_name      = $name,
                            $ionice_args        = undef,
                            $rsync_path         = undef,
                            $exclude            = [],
                            $exclude_from       = undef,
                            $delete             = false,
                            $compress           = false,
                            $check_file         = undef,
                            $expected_fs        = undef,
                            $expected_remote_fs = undef,
                            $default_reverse    = false,
                            $order              = '42',
                          ) {
  include rsync::manager

  concat::fragment{ "/etc/rsyncman/${schedule_name}.conf ${path}":
    target  => "/etc/rsyncman/${schedule_name}.conf",
    order   => "b${order}",
    content => template("${module_name}/rsyncman/job.erb"),
  }
}
