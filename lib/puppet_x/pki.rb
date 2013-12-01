module PuppetX
  module PKI

    def retrieve(options={})
      catalog = options[:catalog]
      res_ref = options[:resource_ref].to_s
      Puppet.debug "Searching catalogs for #{res_ref}"
      res = catalog.resource(res_ref)
      res.to_hash
    end
  end
end
