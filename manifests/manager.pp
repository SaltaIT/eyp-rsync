class rsync::manager(
                      $logdir_owner = 'root',
                      $logdir_group = 'root',
                      $logdir_mode = '0750',
                    ) inherits rsync::params{

  include ::rsync

  Class['::rsync'] ->
  class { '::rsync::manager::install': } ->
  Class['::rsync::manager']

}
