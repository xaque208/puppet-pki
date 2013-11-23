Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    debug "create #{resource[:name]}"
    gen_csr()
    sign_csr()
    remove_csr()
  end

  def destroy
    debug "destroy #{resource[:name]}"
    revoke()
    gen_crl()
    remove_keypair()
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
    begin
      openssl(cmd)
    end
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

  def revoke
    debug "Revoking certificate"
    ca_resource()

    cmd = [
      'ca',
      '-config',
      confpath(),
      '-revoke',
      certpath(),
      '-keyfile',
      cakeypath(),
      '-cert',
      cacertpath(),
    ]
    openssl(cmd)
  end

  def remove_csr
    if File.exists?(reqpath())
      File.unlink(reqpath())
    end
  end

  def remove_keypair
    if File.exists?(certpath())
      File.unlink(certpath())
    end

    if File.exists?(keypath())
      File.unlink(keypath())
    end
  end

  def gen_crl
    debug "Revoking certificate"
    ca_resource()

    cmd = [
      'ca',
      '-config',
      confpath(),
      '-gencrl',
      '-keyfile',
      cakeypath(),
      '-cert',
      cacertpath(),
      '-out',
      crlpath()
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

  def crlpath
    @resource[:pki_dir] + '/' + ca_name() + '/crl.pem'
  end

  def ca_resource
    if @ca
      debug "Found CA"
      return @ca
    else
      debug "CA not found, fetching"
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
