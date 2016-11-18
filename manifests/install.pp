class rsync::install inherits rsync {

  if($rsync::manage_package)
  {
    package { $rsync::params::package_name:
      ensure => $rsync::package_ensure,
    }
  }

}
