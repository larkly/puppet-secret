
Puppet::Parser::Functions::newfunction(:secret, :type => :rvalue) do |vals|
  secretid = vals[0] || 'default'

  # get the callee (secrets are saved based on fqdn)
  callee = lookupvar('fqdn')
  if callee.to_s.empty?
    raise Puppet::ParseError, "missing fully qualified domain name for callee of function 'secret()'. can't proceed without fqdn."
  end
  
  # point the client to his secret
  return "puppet:///secrets/secret"
end