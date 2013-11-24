# Leverages EasyRSA to build out a new CA or Intermediate CA.
define pki::ca (
  $pki_dir,
  $ca_expire   = '3650',
  $ca_size     = '4096',
  $expire      = '365',
  $size        = '2048',
  $country     = 'US',
  $province    = 'OR',
  $city        = "Portland",
  $email       = "admin@example.con",
  $org         = "Security",
  $ca_name     = "Root",
  $ou          = "Pki",
  $parent      = undef,
  #$dh          = false,
) {

  $cn   = $name
  $dest = "${pki_dir}/${cn}"

  # Prepare the CA directory structure
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

  # EasyRSA Deprecation
  #
  $easy_rsa_files = [
    "${dest}/vars",
    "${dest}/whichopensslcnf",
    "${dest}/pkitool",
    "${dest}/clean-all",
    "${dest}/build-dh",
    "${dest}/openssl-1.0.0.cnf",
  ]

  file { $easy_rsa_files:
    ensure  => absent,
  }

  #if $dh == true {
  #  # Build the Diffie Hellman key.
  #  exec { "Build DH at ${dest}":
  #    cwd     => $dest,
  #    command => "/bin/bash -c \"(source $dest/vars > /dev/null; ${dest}/build-dh ${key_size})\"",
  #    creates => "${dest}/keys/dh${key_size}.pem",
  #  }
  #}

}
