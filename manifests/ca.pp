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
  #$name        = "Root",
  $ou          = "Pki",
  $source_key  = '',
  $source_cert = '',
  $dh          = false,
  $rootca_path = ''
) {

  $cn = $name
  $dest   = "${pki_dir}/${cn}"

  #$environment = [
  #  "CA_EXPIRE=${ca_expire}",
  #  "KEY_EXPIRE=${key_expire}",
  #  "KEY_SIZE=${key_size}",
  #  "KEY_COUNTRY=${key_country}",
  #  "KEY_PROVINCE=${key_province}",
  #  "KEY_CITY=${key_city}",
  #  "KEY_EMAIL=${key_email}",
  #  "KEY_ORG=${key_org}",
  #  "KEY_CN=${key_cn}",
  #  "KEY_OU=${key_ou}",
  #  "KEY_NAME=${key_name}",
  #]

  #Exec {
  #  environment => $environment,
  #}

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

  # Write the paramaters to the 'vars' script.
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

