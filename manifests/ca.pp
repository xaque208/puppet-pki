# Leverages EasyRSA to build out a new CA or Intermediate CA.
define pki::ca (
  $pki_dir,
  $ca_expire   = '3650',
  $ca_size     = '4096',
  $expire      = '365',
  $size        = '1024',
  $country     = 'US',
  $province    = 'OR',
  $city        = "Portland",
  $email       = "admin@example.con",
  $org         = "Security",
  $ca_name     = "Root",
  $ou          = "Pki",
  #$source_key  = '',
  #$source_cert = '',
  #$dh          = false,
  $rootca_path = '',
) {

  $cn   = $name
  $dest = "${pki_dir}/${cn}"

  file { $dest:
    ensure => directory,
    mode   => '0700',
  }->

  file {
    "${dest}/private": ensure => directory;
    "${dest}/certs":   ensure => directory;
    "${dest}/reqs":    ensure => directory;
  }->

  file { "${dest}/openssl.cnf":
    content => template('pki/openssl.cnf.erb'),
    require => File[$dest],
  }->

  file { "${dest}/index.txt":
    ensure  => present,
    require => File[$dest],
  }->

  file { "${dest}/serial":
    content => '000a',
    replace => false,
    require => File[$dest],
  }

  # Use the keypair from the parent CA if we have speified one
  #
  if ($parent) {

    $source_cert = '/Users/zach/Org/n3kl/pki/n3kl.cx/certs/ca.crt'
    $source_key = '/Users/zach/Org/n3kl/pki/n3kl.cx/private/ca.key'

    # Copy in an existing CA.
    file { "${dest}/certs/ca.crt":
      source  => $source_cert,
      mode    => 0444,
      require => $parent,
    }
    file { "${dest}/private/ca.key":
      source  => $source_key,
      mode    => 0400,
      require => $parent,
    }
  } else {

    # Generate a keypair for the SSL CA if we don't have a parent
    #
    ssl_ca { $name:
      pki_dir   => $pki_dir,
      expire    => $ca_expire,
      size      => $ca_size,
      require => File[$dest],
    }->

    # Set some permissions
    file { "${dest}/certs/ca.crt":
      mode    => 0444,
    }->

    file { "${dest}/private/ca.key":
      mode    => 0400,
    }
  }

  # clean up old vars script from EasyRSA
  file { "${dest}/vars":
    ensure  => absent,
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

