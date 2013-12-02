require 'puppet_x/pki'

include PuppetX::PKI

module Puppet::Parser::Functions
  newfunction(:retrieve_resource_hash, :type => :rvalue) do |args|
    res_ref = args.first
    res_hash ||= retrieve(
      :resource_ref => res_ref,
      :catalog      => self.catalog
    )

    new_hash = Hash.new
    res_hash.each do |k,v|
      new_hash[k.to_s] = res_hash[k]
    end
    new_hash
  end
end
