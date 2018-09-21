class rsync::manager() inherits rsync::params{

  include ::rsync

  Class['::rsync'] ->
  class { '::rsync::manager::install': } ->
  Class['::rsync::manager']

}
