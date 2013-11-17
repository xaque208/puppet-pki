Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    debug "create #{resource[:name]}"
    gen_csr()
    sign_csr()
  end

  def destroy
    debug "destroy #{resource[:name]}"
    revoke()
    destroy()
  end

  def exists?
    File.exists?(certpath()) and File.exists?(keypath())
  end

  def gen_csr
    debug "Generating CSR"
    debug @resource.inspect

    ca_resource()
    debug @ca.inspect

    cmd = [
      'req',
      '-config',
      confpath(),
      '-batch',
      '-days',
      @resource[:expire],
      '-nodes',
      '-new',
      '-newkey',
      "rsa:" + @resource[:size],
      '-keyout',
      keypath(),
      '-out',
      reqpath(),
    ]
    openssl(cmd)
  end

  def sign_csr
    debug "Signing certificate"
    ca_resource()

    cmd = [
      'ca',
      '-config',
      confpath(),
      '-batch',
      '-out',
      certpath(),
      '-in',
      reqpath(),
      '-keyfile',
      cakeypath(),
      '-cert',
      cacertpath(),
      '-outdir',
      @resource[:pki_dir] + '/' + ca_name() + '/certs',
    ]
    openssl(cmd)
  end

  def confpath
    @resource[:pki_dir] + '/' + ca_name() + '/openssl.cnf'
  end

  def certpath
    @resource[:pki_dir] + '/' + ca_name() + '/certs/' + @resource[:name] + '.crt'
  end

  def keypath
    @resource[:pki_dir] + '/' + ca_name() + '/private/' + @resource[:name] + '.key'
  end

  def reqpath
    @resource[:pki_dir] + '/' + ca_name() + '/reqs/' + @resource[:name] + '.csr'
  end

  def ca_resource
    if @ca
      debug "Found CA"
      return @ca
    else
      debug "CA not found"
      @ca = @resource.get_ca(@resource[:ca])
    end
  end

  def cacertpath
    ca_resource()
    ca_pki_dir() + '/' + ca_name() + '/certs/ca.crt'
  end

  def cakeypath
    ca_resource()
    ca_pki_dir() + '/' + ca_name() + '/private/ca.key'
  end

  def ca_name
    ca_resource()
    @ca.to_hash[:name]
  end

  def ca_pki_dir
    ca_resource()
    @ca.to_hash[:pki_dir]
  end

end
