Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    Puppet.debug "create #{resource[:name]}"

    # initialize the variables
    ca()
    pki()

    gen_csr()
    sign_csr()
    remove_csr()
  end

  def destroy
    Puppet.debug "destroy #{resource[:name]}"
    revoke()
    gen_crl()
    remove_keypair()
  end

  def exists?
    ca()
    File.exists?(certpath()) and File.exists?(keypath())
  end

  def gen_csr
    Puppet.debug "Generating CSR"
    Puppet.debug @resource.inspect

    ca()
    Puppet.debug @ca.inspect

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

    # Add the server extensions if requested
    if @resource[:is_server]
      cmd << '-extensions'
      cmd << 'server'
    end

    # Are we building a CA
    if @resource[:is_ca]
      if @resource[:is_server]
        fail("Building a cerver cert that is also a CA seems dumb")
      end
      cmd << '-extensions'
      cmd << 'v3_ca'
    end

    begin
      Puppet.debug cmd
      openssl(cmd)
    end
  end

  def sign_csr
    Puppet.debug "Signing certificate"
    ca()

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
      directory() + '/certs',
    ]

    # Add the server extensions if requested
    if @resource[:is_server]
      cmd << '-extensions'
      cmd << 'server'
    end

    # Are we building a CA
    if @resource[:is_ca]
      if @resource[:is_server]
        fail("Building a cerver cert that is also a CA seems dumb")
      end
      cmd << '-extensions'
      cmd << 'v3_ca'
    end

    begin
      Puppet.debug cmd
      openssl(cmd)
    end
  end

  def revoke
    Puppet.debug "Revoking certificate"
    ca()

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
    Puppet.debug "Revoking certificate"
    ca()

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
    directory() + '/openssl.cnf'
  end

  def certpath
    directory() + '/certs/' + @resource[:name] + '.crt'
  end

  def keypath
    directory() + '/private/' + @resource[:name] + '.key'
  end

  def reqpath
    directory() + '/reqs/' + @resource[:name] + '.csr'
  end

  def crlpath
    directory() + '/crl.pem'
  end

  def cacertpath
    directory() + '/certs/ca.crt'
  end

  def cakeypath
    directory() + '/private/ca.key'
  end

  def ca_name
    @ca[:name]
  end

  def directory
    pki()
    Puppet.debug "fetching ca directory"
    @directory ||= @pki[:directory] + '/' + ca_name()
  end

  def self.ca(resource)
    @ca ||= PuppetX::PKI.retrieve(:resource_ref => resource[:ca], :catalog => resource.catalog)
  end

  def ca
    @ca ||= self.class.ca(resource)
  end

  def self.pki(resource)
    @pki ||= PuppetX::PKI.retrieve(:resource_ref => resource[:pki], :catalog => resource.catalog)
  end

  def pki
    @pki ||= self.class.pki(resource)
  end
end
