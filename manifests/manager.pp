class rsync::manager(
                    ) inherits rsync::params{

  class { '::rsync::manager::install': } ->
  Class['::rsync::manager']

}
