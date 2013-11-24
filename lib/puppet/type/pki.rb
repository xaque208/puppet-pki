require 'pathname'

Puppet::Type.newtype(:pki) do

  newparam(:name, :namevar => :true) do
    desc "The name of the PKI"
  end

  newparam(:directory) do
    defaultto '/usr/local/pki'
    validate do |v|
      fail('directory should be absolute') unless Pathname.new(v).absolute?
    end
  end
end
