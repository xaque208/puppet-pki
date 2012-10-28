# Install EasyRSA to the specified directory.
define pki (
  $dest
  ) {

  file { $dest:
    source => "puppet:///modules/pki/easyrsa",
    recurse => true,
    replace => false,
  }

  file { "${dest}/openssl-1.0.0.cnf":
    ensure  => link,
    target  => "${dest}/openssl.cnf",
    require => File[$dest],
  }

}
