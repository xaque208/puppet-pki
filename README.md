# PKI Management with Puppet

All of the OpenSSL work is currently done by the tools provided in EasyRSA from
the OpenVPN 2.2.2 source, with the intention that some will be replaced by
calling the OpenSSL commands directly.

This is still very much an experiment, but I would like to be able to manage
keys associated with each of these CAs and start deploying certificates for
things like VPNs, MCollective, and Nginx virtual hosts using intermediate CAs.
Some of the CAs, like the example for Puppet below will not manage keys
directly, but simply prepare the environment so that you do have a true chain
of trust.  Obviously this is of little use to you unless you install the RootCA
certificate yourself.  Luckily, Puppet is very good at this.

## Usage

### Generate the Root CA

    $pki_dir = "/Users/zach/devel/pki"

    pki::ca { "Root":
      pki_dir     => $pki_dir,
      key_email    => "ssl@example.com",
      key_size     => 2048,
      key_country  => "US",
      key_province => "OR",
      key_city     => "Portland",
      key_org      => "Acme",
      dh           => false,
    }

#### What this does

This installs EasyRSA to the directory specified as `$pki_dir/$name`.  In this
case `/Users/zach/devel/pki/Root`.  Once complete, `pkitool` is called to
generate a new CA, building the environment out of the specified parameters.


### Generate an Intermediate CAs

So far, this builds a certificate/key pair for each `pki::interca` specified and signs them with the RootCA, specified at the location `rootca`.

Set resource defaults for a simpler manifest:

    Pki::Interca {
      pki_dir      => $pki_dir,
      rootca       => "Root",
      key_email    => "ssl@example.com",
      key_size     => 2048,
      key_country  => "US",
      key_province => "OR",
      key_city     => "Portland",
      key_org      => "TestCo",
    }

Provide the resources to generate the intermediate CAs:

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

#### What this does

This creates several intermediate CAs in the root CA located at `$pki_dir/Root`
and then proceeds to create new EasyRSA installations using the generated in
the root, as the CA keypair as the newly generated intermediate CA keypair.

### Create a Server Keypair

We are not able to start generating server certificates for a given intermediate CA.

    Pki::Serverkey {
      pki_dir => $pki_dir,
    }

    pki::serverkey { "tickets.example.com":
      rootca   => 'TechOps',
      key_name => 'Example.com Ticket Tracker',
    }

#### What this does

This creates a server keypair for the CA specified, following the same manner above.

## Contributers

* Zach Leslie <zach@puppetlabs.com>

