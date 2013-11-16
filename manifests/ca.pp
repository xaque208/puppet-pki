# Leverages EasyRSA to build out a new CA or Intermediate CA.
define pki::ca (
  $pki_dir,
  $ca_expire   = '3650',
  $expire      = '365',
  $size        = '1024',
  $country     = 'US',
  $province    = 'OR',
  $city        = "Portland",
  $email       = "admin@example.con",
  $org         = "Acme",
  $ca_name     = "Root",
  $ou          = "Pki",
  $source_key  = '',
  $source_cert = '',
  $dh          = false,
  $rootca_path = '',
  $ca_expire   = '1780',
  $ca_size     = '2048'
) {

  $cn   = $name
  $dest = "${pki_dir}/${cn}"

  file {
    $dest:           ensure => directory;
    "${dest}/ca":    ensure => directory;
    "${dest}/keys":  ensure => directory;
    "${dest}/certs": ensure => directory;
  }

  file { "${dest}/openssl.cnf":
    content => template('pki/openssl.cnf.erb'),
    require => File[$dest],
  }

  # clean up old vars script from EasyRSA
  file { "${dest}/vars":
    ensure  => absent,
  }

  ssl_ca { $name:
    directory => "${dest}/ca",
    expire    => $ca_expire,
    size      => $ca_size,
  }

  # Determine if we should build a new CA or copy in an existing.
  #if ( $source_key != '' and $source_cert != '' ) {

  #  # Copy in an existing CA.
  #  file { "${dest}/keys/ca.crt":
  #    source  => $source_cert,
  #    mode    => 0644,
  #    require => Exec["Clean All at ${dest}"],
  #  }
  #  file { "${dest}/keys/ca.key":
  #    source  => $source_key,
  #    mode    => 0644,
  #    require => Exec["Clean All at ${dest}"],
  #  }

  #} else {

  #  # Generate a new CA.
  #  pki::pkitool { "CA at ${dest}":
  #    command     => "--initca",
  #    creates     => "${dest}/keys/ca.crt",
  #    base_dir    => $dest,
  #    environment => $environment,
  #    require     => Exec["Clean All at ${dest}"],
  #  }

  #}

  #if $dh == true {
  #  # Build the Diffie Hellman key.
  #  exec { "Build DH at ${dest}":
  #    cwd     => $dest,
  #    command => "/bin/bash -c \"(source $dest/vars > /dev/null; ${dest}/build-dh ${key_size})\"",
  #    creates => "${dest}/keys/dh${key_size}.pem",
  #  }
  #}

}

