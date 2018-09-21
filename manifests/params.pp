class rsync::params {

  $package_name='rsync'
  $rsyncman_dependencies = [ 'python-psutil' ]

  case $::osfamily
  {
    'redhat': { }
    'Debian': { }
    'Suse' : { }
    default: { fail('Unsupported OS!')  }
  }
}
