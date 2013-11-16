Puppet::Type.type(:ssl_ca).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    debug "creating #{resource[:name]}"
    gen_ca()

  end

  def destroy
    false
  end

  def exists?
    prefix = @resource[:directory] + '/ca'
    certpath = prefix + '/ca.crt'
    keypath = prefix + '/ca.key'
    File.exists?(certpath) and File.exists?(keypath)
  end

  private

  def gen_ca
    debug "Generating CA"

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
      @resource[:directory] + '/ca.key',
      '-out',
      @resource[:directory] + '/ca.csr',
    ]
    openssl(cmd)
  end

end

