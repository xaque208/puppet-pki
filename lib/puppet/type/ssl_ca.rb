Puppet::Type.newtype(:ssl_ca) do
  @doc = "Manage an SSL CA."

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
    desc "The name of the CA.  Used as the directory name under the PKI directory."
    isnamevar
    isrequired
  end

  newparam(:expire) do
    desc "How many days the key should be valid for."
    defaultto '1780'
  end

  newparam(:size) do
    desc "How many bits the key should be."
    defaultto '2048'
  end

  newparam(:pki, :isrequired => true) do
    desc "The PKI to use."
  end

  autorequire(:pki) do
    self[:pki]
  end
end
