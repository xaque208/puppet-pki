define pki::interca (
    $key_size     = '1024',
    $ca_expire    = '3650',
    $key_expire   = '3650',
    $key_country  = 'US',
    $key_province = 'OR',
    $key_city     = "Portland",
    $key_email    = "admin@foo.bar",
    $key_org      = "Acme",
    $key_name     = "Root",
    $key_ou       = "TechOps",
    $dh           = false,
    $pki_dir,     # The directory to store all of the PKI CAs.
    $rootca       # The name of the CA to use as the root, located within the $pki_dir
) {

  $key_cn = $name
  $dest   = "${pki_dir}/${key_cn}"

  $environment = [ 
    "CA_EXPIRE=${ca_expire}",
    "KEY_EXPIRE=${key_expire}",
    "KEY_SIZE=${key_size}",
    "KEY_COUNTRY=${key_country}",
    "KEY_PROVINCE=${key_province}",
    "KEY_CITY=${key_city}",
    "KEY_EMAIL=${key_email}",
    "KEY_ORG=${key_org}",
    "KEY_CN=${key_cn}",
    "KEY_OU=${key_ou}",
    "KEY_NAME=${key_name}",
  ]

  # Build the Intermediate CA and sign it with the root CA
  pki::pkitool { "Intermediate CA for ${key_cn} at ${rootca}":
    command     => "--inter ${key_cn}",
    creates     => "${pki_dir}/${rootca}/keys/${key_cn}.crt",
    base_dir    => "${pki_dir}/${rootca}",
    environment => $environment,
    require     => Pki::Ca[$rootca],
  }

  # Build a CA using the Key/Cert signed by the root CA.
  pki::ca { $key_cn:
    ca_expire    => $ca_expire,
    key_size     => $key_size,
    key_expire   => $key_expire,
    key_country  => $key_country,
    key_province => $key_province,
    key_city     => $key_city,
    key_email    => $key_email,
    key_org      => $key_org,
    key_name     => $key_name,
    key_ou       => $key_ou,
    pki_dir      => $pki_dir,
    dh           => $dh,
    source_key   => "${pki_dir}/${rootca}/keys/${key_cn}.key",
    source_cert  => "${pki_dir}/${rootca}/keys/${key_cn}.crt",
    require      => Pki::Pkitool["Intermediate CA for ${key_cn} at ${rootca}"],
  }

}

