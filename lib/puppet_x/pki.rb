module PuppetX
  module PKI

    def retrieve(options={})
      catalog = options[:catalog]
      res_ref = options[:resource_ref].to_s
      res_hash = catalog.resource(res_ref).to_hash
      res_hash
    end
  end
end
