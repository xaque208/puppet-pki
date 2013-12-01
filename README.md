# PKI Management with Puppet

Puppet-pki is a module to deploy a full PKI described in Puppet manifests.

This was once implemented using EasyRSA, but currently being converted into
nearly-pure Puppet.

Still a work in progress, and therefore an experiment, but I have a plan.

## The Goal

To manage the processes associated with building a CA and its chain, including 

  * Chained Certificate Authorities
  * Certificate Signing Requests signing for each CA
  * Certificate Revocations
  * Revocation list deployment
  * Certificate Deployment using Puppet

## Usage

### Generate the Root CA

First we need to create the directory structure necessary to build a CA.  Create a `pki` resource that the rest of the resources can reference.

    $pki_dir = "/usr/local/pki"

    pki { "example.com":
      directory => $pki_dir,
    }

Then deploy a root CA under it, using the `pki` resource from above.

    pki::ca { "Root":
      email    => "ssl@example.com",
      size     => 2048,
      country  => "US",
      province => "OR",
      city     => "Portland",
      org      => "SomewhereCool",
      pki      => Pki["example.com"],
    }

This will build a self signed CA in `$pki_dir/Root` as specified by the name of
the resource.

You can now begin to build out your chain of trust.  To start with, create an Intermediate CA, referencing the Root CA above using the `parent` parameter and the `pki` parameter as before.

### Chaining Authorities Together

    pki::ca { "Lab":
      email    => "ssl@example.com",
      size     => 2048,
      country  => "US",
      province => "OR",
      city     => "Portland",
      org      => "SomewhereCool",
      parent   => Pki::Ca["Root"],
      pki      => Pki["example.com"],
    }

This will do the following

* create the directory structure for the new CA
* create a keypair for the new CA in the parent CA
* copy the keypair from the parent to the child CA

## Next Steps

* Become reliable

## Contributers

* Zach Leslie <zach@puppetlabs.com>

