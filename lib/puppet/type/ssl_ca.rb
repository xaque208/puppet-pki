require 'pathname'

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

  # WRONG!!
  #autorequire(:file) do
  #  self[:directory] + '/openssl.cnf'
  #end

  newparam(:name) do
    desc "The name of the CA, as well as the directory in the pki_dir.  See below."
    isnamevar
    isrequired
  end

  newparam(:pki_dir) do
    desc "The root directory of the PKI."
    defaultto '/opt/pki'
    validate do |v|
      fail('directory should be absolute') unless Pathname.new(v).absolute?
    end
  end

  newparam(:expire) do
    desc "How many days the key should be valid for."
    defaultto '1780'
  end

  newparam(:size) do
    desc "How many bits the key should be."
    defaultto '2048'
  end

end
