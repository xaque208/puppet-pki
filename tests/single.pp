# A test PKI built by puppet

$pki_dir = "/Users/zach/devel/pki"

pki { "dev":
  directory => $pki_dir,
}

Pki::Ca {
  pki => Pki["dev"],
}

Ssl_keypair {
  pki => Pki["dev"],
}

pki::ca { "Test":
  email   => "ops@example.com",
}

ssl_keypair { "testcert0.example.com":
  ca      => Pki::Ca['Test'],
}

ssl_keypair { "testcert1.example.com":
  ca      => Pki::Ca['Test'],
}

ssl_keypair { "testcert2.example.com":
  ca      => Pki::Ca['Test'],
}
