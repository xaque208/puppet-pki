require 'pathname'

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

  autorequire(:file) do
    self[:directory] + '/openssl.cnf' if self[:directory]
  end

  newparam(:name) do
    desc "The certificate name"
    isnamevar
    isrequired
  end

  newparam(:directory) do
    desc "The certificate name"
    defaultto '/opt/pki'
    validate do |v|
      fail('directory should be absolute') unless Pathname.new(v).absolute?
    end
  end

  newparam(:ca_dir) do
    desc "The directory containing the ca.{key,crt} files"
    defaultto '/opt/pki'
    validate do |v|
      fail('directory should be absolute') unless Pathname.new(v).absolute?
    end
  end

  newparam(:expire) do
    desc "How many days the key should be valid for."
    defaultto '365'
  end

  newparam(:size) do
    desc "How many bits the key should be."
    defaultto '2048'
  end

  newparam(:country) do
    defaultto 'US'
    validate do |v|
      fail('country should be a string') unless v.is_a? String
    end
  end

  newparam(:province) do
    defaultto 'OR'
    validate do |v|
      fail('province should be a string') unless v.is_a? String
    end
  end

  newparam(:city) do
    defaultto 'Portland'
    validate do |v|
      fail('city should be a string') unless v.is_a? String
    end
  end

  newparam(:email) do
    validate do |v|
      fail('email should be a string') unless v.is_a? String
    end
  end

  newparam(:org) do
    validate do |v|
      fail('org should be a string') unless v.is_a? String
    end
  end

  newparam(:ou) do
    validate do |v|
      fail('ou should be a string') unless v.is_a? String
    end
  end

end
