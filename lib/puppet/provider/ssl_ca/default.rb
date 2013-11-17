Puppet::Type.type(:ssl_ca).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    debug "Creating new CA #{resource[:name]}"
    gen_ca()
    #sign_ca_cert()
  end

  def destroy
    #not implemented
    nil
  end

  def exists?
    debug "Searching for existing CA"
    File.exists?(certpath()) and File.exists?(keypath())
  end

  private

  def gen_ca

    cmd = [
      'req',
      '-config',
      confpath(),
      '-batch',
      '-days',
      @resource[:expire],
      '-nodes',
      #'-new',
      '-newkey',
      "rsa:#{@resource[:size]}",
      '-keyout',
      keypath(),
      '-x509',
      '-out',
      certpath()
    ]

    openssl(cmd)
  end

  def certpath
    @resource[:pki_dir] + '/' + @resource[:name] + '/certs/ca.crt'
  end

  def keypath
    @resource[:pki_dir] + '/' + @resource[:name] + '/private/ca.key'
  end

  def confpath
    @resource[:pki_dir] + '/' + @resource[:name] + '/openssl.cnf'
  end

  def reqpath
    @resource[:pki_dir] + '/' + @resource[:name] + '/reqs/ca.csr'
  end

end

