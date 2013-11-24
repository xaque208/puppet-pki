require 'puppet_x/pki'

include PuppetX::PKI

Puppet::Type.type(:ssl_ca).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    Puppet.debug "Creating new CA #{resource[:name]}"
    pki()
    gen_ca()
    #sign_ca_cert()
  end

  def destroy
    #not implemented
    nil
  end

  def exists?
    Puppet.debug "Searching for existing CA"
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
    directory() + '/certs/ca.crt'
  end

  def keypath
    directory() + '/private/ca.key'
  end

  def confpath
    directory() + '/openssl.cnf'
  end

  def reqpath
    directory() + '/reqs/ca.csr'
  end

  def directory
    pki()
    @directory ||= @pki[:directory] + '/' + @resource[:name]
  end

  def self.pki(resource)
    @pki ||= PuppetX::PKI.retrieve(:resource_ref => resource[:pki], :catalog => resource.catalog)
  end

  def pki
    @pki ||= self.class.pki(resource)
  end
end

