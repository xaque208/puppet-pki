Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  commands :openssl => 'openssl'

  def create
    Puppet.debug "Creating keypair for #{resource[:name]}"

    # Load variable hash
    vars()

    # Perform
    gen_csr()
    sign_csr()
    remove_csr()
  end

  def destroy
    Puppet.debug "Destroying keypair for #{resource[:name]}"

    # Load variable hash
    vars()

    # Perform
    revoke()
    gen_crl()
    remove_keypair()
  end

  def exists?
    vars()
    File.exists?(@vars[:certpath]) and File.exists?(@vars[:keypath])
  end

  def gen_csr
    Puppet.debug "Generating CSR for #{resource[:name]}"

    cmd = [
      'req',
      '-config',
      @vars[:confpath],
      '-batch',
      '-days',
      @resource[:expire],
      '-nodes',
      '-new',
      '-newkey',
      "rsa:" + @resource[:size],
      '-keyout',
      @vars[:keypath],
      '-out',
      @vars[:reqpath],
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

    subj = []
    subj << 'C=' + @resource[:country] if @resource[:country]
    subj << 'ST=' + @resource[:province] if @resource[:province]
    subj << 'L=' + @resource[:city] if @resource[:city]
    subj << 'O=' + @resource[:org] if @resource[:org]
    subj << 'OU=' + @resource[:ou] if @resource[:ou]

    if @resource[:cn]
      common_name = []
      common_name << 'CN=' + @resource[:cn]
      common_name << 'name=' + @resource[:name]
      common_name << 'emailAddress=' + @resource[:email] if @resource[:email]

      subj << common_name.join('/')
    else
      subj << 'CN=' + @resource[:name]
    end

    cmd << '-subj'
    cmd << '/' + subj.join('/')

    begin
      openssl(cmd)
    end
  end

  def sign_csr
    Puppet.debug "Signing certificate for #{resource[:name]}"

    cmd = [
      'ca',
      '-config',
      @vars[:confpath],
      '-batch',
      '-out',
      @vars[:certpath],
      '-in',
      @vars[:reqpath],
      '-keyfile',
      @vars[:cakeypath],
      '-cert',
      @vars[:cacertpath],
      '-outdir',
      @vars[:certsdir],
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
      openssl(cmd)
    end
  end

  def revoke
    Puppet.debug "Revoking certificate"

    cmd = [
      'ca',
      '-config',
      @vars[:confpath],
      '-revoke',
      @vars[:certpath],
      '-keyfile',
      @vars[:cakeypath],
      '-cert',
      @vars[:cacertpath],
    ]

    openssl(cmd)
  end

  def remove_csr
    if File.exists?(@vars[:reqpath])
      File.unlink(@vars[:reqpath])
    end
  end

  def remove_keypair
    if File.exists?(@vars[:certpath])
      File.unlink(@vars[:certpath])
    end

    if File.exists?(@vars[:keypath])
      File.unlink(@vars[:keypath])
    end
  end

  def gen_crl
    Puppet.debug "Revoking certificate"

    cmd = [
      'ca',
      '-config',
      @vars[:confpath],
      '-gencrl',
      '-keyfile',
      @vars[:cakeypath],
      '-cert',
      @vars[:cacertpath],
      '-out',
      @vars[:crlpath]
    ]

    openssl(cmd)
  end

  def vars
    @vars = {
      :directory  => directory(),
      :confpath   => confpath(),
      :certpath   => certpath(),
      :keypath    => keypath(),
      :reqpath    => reqpath(),
      :crlpath    => crlpath(),
      :cacertpath => cacertpath(),
      :cakeypath  => cakeypath(),
      :ca_name    => ca_name(),
    }

    @vars[:certsdir] = @vars[:directory] + '/certs'

    @vars
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
    ca()
    @ca[:name]
  end

  def directory
    pki()
    @pki[:directory] + '/' + ca_name()
  end

  # Get info from the CA resource
  def self.ca(resource)
    @ca = PuppetX::PKI.retrieve(:resource_ref => resource[:ca], :catalog => resource.catalog)
  end

  def ca
    @ca = self.class.ca(resource)
  end

  # Get info from the PKI resource
  def self.pki(resource)
    @pki = PuppetX::PKI.retrieve(:resource_ref => resource[:pki], :catalog => resource.catalog)
  end

  def pki
    @pki = self.class.pki(resource)
  end
end
