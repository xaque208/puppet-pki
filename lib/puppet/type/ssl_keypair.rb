require 'pathname'
require 'pp'

Puppet::Type.newtype(:ssl_keypair) do
  @doc = "Manage an SSL key pair."

  ensurable do
    defaultto :present

    newvalue(:present, :event => :keypair_created) do
      provider.create
    end

    newvalue(:absent, :event => :keypair_destroyed) do
      provider.destroy
    end
  end

  newparam(:name) do
    desc "The certificate name"
    isnamevar
    isrequired
  end

  newparam(:expire) do
    desc "How many days the key should be valid for."
    defaultto '365'
  end

  newparam(:size) do
    desc "How many bits the key should be."
    defaultto '2048'
  end

  # Used when building a server keypair
  newparam(:is_server) do
    desc "Turn on the server extensions for this certificate"
    defaultto false
    validate do |v|
      fail('server should be true or false') unless v == true or v == false
    end
  end

  # Used when we are building a child CA
  newparam(:is_ca) do
    desc "Turn on the CA extensions for this certificate"
    defaultto false
    validate do |v|
      fail('we are either a ca or we are not') unless v == true or v == false
    end
  end

  newparam(:ca, :isrequired => true) do
    desc "The resource name of the CA"
  end

  newparam(:pki, :isrequired => true) do
    desc "The PKI to use."
  end

  autorequire(:ssl_ca) do
    self[:ca]
  end

  autorequire(:pki) do
    self[:pki]
  end
end
