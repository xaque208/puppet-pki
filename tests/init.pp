$pki_dir = "/Users/zach/devel/pki"

pki::ca { "Root":
  pki_dir     => $pki_dir,
  key_email    => "ssl@example.com",
  key_size     => 2048,
  key_country  => "US",
  key_province => "OR",
  key_city     => "Portland",
  key_org      => "TestCo",
  dh           => false,
}

Pki::Interca { 
  pki_dir      => $pki_dir,
  rootca       => "Root",
  key_email    => "ssl@example.com",
  key_size     => 2048,
  key_country  => "US",
  key_province => "OR",
  key_city     => "Portland",
  key_org      => "TestCo",
  require      => Pki::Ca["Root"],
}

pki::interca { "VPN":
  dh => true,
}
pki::interca { "MCollective": 
}
pki::interca { "Puppet": 
}
pki::interca { "TechOps": 
  key_email    => "techops@example.com",
  key_name     => "TechOps",
}


#pki::key { "reuk.n3kl.cx": ca => "VPN" }

