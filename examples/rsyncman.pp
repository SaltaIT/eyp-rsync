class { 'rsync::manager':
}

rsync::manager::schedule { 'demo':
  mail_to => 'jordi@systemadmin.es',
  host_id => 'demopuppet',
}

rsync::manager::job { 'demo':
  path        => '/demo',
  remote      => 'jprats@127.0.0.1',
  exclude     => [ 'a', 'b', 'c' ],
  remote_path => '/demo2',
}
