module Puppet::Parser::Functions
  newfunction(:retrieve_resource_name, :type => :rvalue) do |args|
    rec_type, rec_name = args.first.name.split('/')
    rec_name
  end
end
