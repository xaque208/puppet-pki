define pki::pkitool (
    $base_dir,
    $command,
    $creates,
    $environment
){

  exec { $title:
    cwd         => $base_dir,
    command     => "/bin/bash -c \"(source ${base_dir}/vars > /dev/null && ${base_dir}/pkitool ${command})\"",
    creates     => $creates,
    environment => $environment,
  }

}
