class rsync(
              $manage_package        = true,
              $package_ensure        = 'installed',
            ) inherits rsync::params{

  class { '::rsync::install': } ->
  class { '::rsync::config': } ->
  Class['::rsync']

}
