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
    prefix = @resource[:directory] + '/' + @resource[:name]
    certpath = prefix + '.crt'
    keypath = prefix + '.key'
    File.exists?(certpath) and File.exists?(keypath)
  end

  private

  def gen_csr
    debug "Generating CSR"

    cmd = [
      'req',
      '-config',
      @resource[:directory] + '/openssl.cnf',
      '-batch',
      '-days',
      @resource[:expire],
      '-nodes',
      '-new',
      '-newkey',
      "rsa:#{@resource[:size]}",
      '-keyout',
      "#{@resource[:directory]}/#{@resource[:name]}.key",
      '-out',
      "#{@resource[:directory]}/#{@resource[:name]}.csr",
    ]
    openssl(cmd)
  end

  def sign_csr
    if ca_exists?
      debug "Signing CSR"

      cmd = [
        'ca',
        '-config',
        @resource[:directory] + '/openssl.cnf',
        '-batch',
        '-out',
        "#{@resource[:directory]}/#{@resource[:name]}.csr",
        '-in',
        "#{@resource[:directory]}/#{@resource[:name]}.csr",
        '-keyfile',
        cakeypath(),
        '-cert',
        cacertpath(),
        '-outdir',
        @resource[:directory] + '/certs',
      ]
      openssl(cmd)
    else
      fail("ca.{crt,key} were not found at the path #{@resouce[:ca_dir]}")
    end
  end

  def ca_exists?
    File.exists?(cacertpath()) and File.exists?(cakeypath())
  end

  def cacertpath
    @resource[:ca_dir] + '/ca.crt'
  end

  def cakeypath
    @resource[:ca_dir] + '/ca.key'
  end

  def certpath

  end

  def keypath

  end

end
