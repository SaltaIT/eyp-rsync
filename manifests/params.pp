class rsync::params {

  $package_name='rsync'

  case $::osfamily
  {
    'redhat':
    {
      case $::operatingsystemrelease
      {
        /^7.*$/:
        {
          $rsyncman_dependencies = [ 'python2-psutil' ]
        }
        default:
        {
          $rsyncman_dependencies = [ 'python-psutil' ]
        }
      }
    }
    'Debian':
    {
      $rsyncman_dependencies = [ 'python-psutil' ]
    }
    'Suse' :
    {
      $rsyncman_dependencies = [ 'python-psutil' ]
    }
    default: { fail('Unsupported OS!')  }
  }
}
