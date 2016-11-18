class rsync(
              $manage_package        = true,
              $package_ensure        = 'installed',
            ) inherits rsync::params{

  validate_re($package_ensure, [ '^present$', '^installed$', '^absent$', '^purged$', '^held$', '^latest$' ], 'Not a supported package_ensure: present/absent/purged/held/latest')

  class { '::rsync::install': } ->
  class { '::rsync::config': } ->
  Class['::rsync']

}
