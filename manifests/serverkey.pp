define pki::serverkey (
    $key_expire   = '365',
    $key_size     = '2048',
    $key_country  = 'US',
    $key_province = 'OR',
    $key_city     = "Portland",
    $key_email    = "admin@example.com",
    $key_org      = "Example",
    $key_ou       = "Operations",
    $key_name,    # ie: Web Server
    $pki_dir,     # ie: /opt/pki
    $rootca       # ie: 'Ops'
) {

  $key_cn = $name
  $dest   = "${pki_dir}/${key_cn}"

  $environment = [
    "KEY_EXPIRE=${key_expire}",
    "KEY_SIZE=${key_size}",
    #"KEY_COUNTRY=${key_country}",
    #"KEY_PROVINCE=${key_province}",
    #"KEY_CITY=${key_city}",
    #"KEY_EMAIL=${key_email}",
    #"KEY_ORG=${key_org}",
    "KEY_CN=${key_cn}",
    #"KEY_OU=${key_ou}",
    "KEY_NAME=${key_name}",
  ]

  pki::pkitool { "Generate server key for ${key_cn} at ${rootca}":
    command     => "--server ${key_cn}",
    creates     => "${pki_dir}/${rootca}/keys/${key_cn}.key",
    base_dir    => "${pki_dir}/${rootca}",
    environment => $environment,
    require     => Pki::Ca[$rootca],
  }

}
