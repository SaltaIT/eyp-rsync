class rsync::service inherits rsync {

  #
  validate_bool($rsync::manage_docker_service)
  validate_bool($rsync::manage_service)
  validate_bool($rsync::service_enable)

  validate_re($rsync::service_ensure, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${rsync::service_ensure}")

  $is_docker_container_var=getvar('::eyp_docker_iscontainer')
  $is_docker_container=str2bool($is_docker_container_var)

  if( $is_docker_container==false or
      $rsync::manage_docker_service)
  {
    if($rsync::manage_service)
    {
      service { $rsync::params::service_name:
        ensure => $rsync::service_ensure,
        enable => $rsync::service_enable,
      }
    }
  }
}
