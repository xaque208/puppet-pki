# A test PKI built by puppet

$pki_dir = "/Users/zach/devel/pki"

pki::ca { "Test":
  pki_dir => $pki_dir,
  email   => "ops@example.com",
}

ssl_keypair { "testcert.example.com":
  pki_dir => $pki_dir,
  ca      => Ssl_ca['Test'],
  require => Pki::Ca['Test'],
}

ssl_keypair { "testcert1.example.com":
  pki_dir => $pki_dir,
  ca      => Ssl_ca['Test'],
  require => Pki::Ca['Test'],
}

ssl_keypair { "testcert2.example.com":
  pki_dir => $pki_dir,
  ca      => Ssl_ca['Test'],
  require => Pki::Ca['Test'],
}
