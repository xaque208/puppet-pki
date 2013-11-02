require 'pp'

Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    debug "create #{resource[:name]}"
    gen_csr()
  end

  def destroy
    debug "destroy #{resource[:name]}"
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

end
