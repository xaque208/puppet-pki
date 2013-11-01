require 'pp'

Puppet::Type.type(:ssl_keypair).provide(:openssl) do

  def create
    debug "create #{resource[:name]}"
    puts "fuck"
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

end
