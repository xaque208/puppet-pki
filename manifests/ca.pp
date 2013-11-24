define pki::ca (
  $ensure      = 'present',
  $pki,
  $ca_expire   = '3650',
  $ca_size     = '4096',
  $expire      = '365',
  $size        = '2048',
  $country     = 'US',
  $province    = 'OR',
  $city        = "Portland",
  $email       = "admin@example.con",
  $org         = "Security",
  $ou          = "Pki",
  $parent      = undef, # a resource like Pki::Ca["Root"]
  #$dh          = false,
) {

  $pki_hash = retrieve_resource_hash($pki)
  $pki_dir  = $pki_hash['directory']

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

    $parent_hash = retrieve_resource_hash($parent)
    $parent_name = retrieve_resource_name($parent)

    $source_cert = "${pki_dir}/${parent_name}/certs/${cn}.crt"
    $source_key  = "${pki_dir}/${parent_name}/private/${cn}.key"

    ssl_keypair { $name:
      ensure  => $ensure,
      pki     => $pki,
      ca      => $parent,
      is_ca   => true,
      require => [
        $parent,
        File["${dest}/serial"],
      ],
    }->

    ## Copy in an existing CA.
    file { "${dest}/certs/ca.crt":
      source  => $source_cert,
      mode    => 0444,
      require => $parent,
    }->
    file { "${dest}/private/ca.key":
      source  => $source_key,
      mode    => 0400,
      require => $parent,
    }
  } else {

    # Generate a keypair for the SSL CA if we don't have a parent
    #
    ssl_ca { $name:
      ensure  => $ensure,
      pki     => $pki,
      expire  => $ca_expire,
      size    => $ca_size,
      require => File["${dest}/serial"],
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
