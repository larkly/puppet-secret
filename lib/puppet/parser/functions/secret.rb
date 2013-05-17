
Puppet::Parser::Functions::newfunction(:secret, :type => :rvalue) do |vals|
  secretid = vals[0] || "default"
  opts = vals[1] || {}

  # get the callee (secrets are saved based on fqdn)
  callee = lookupvar('fqdn')

  # validate all user input
  validate callee, "FQDN"
  validate secretid, "secret ID"

  retrieve_secret( callee, secretid )
  
  # point the client to his secret
  return "puppet:///secrets/secret"
end

def validate sth, name
  if sth.to_s.empty?
    raise Puppet::ParseError, "#{name} for callee of function 'secret()' is empty. can't proceed without it."
  end

  if (sth =~ /^[^\/]*$/).nil?
    raise Puppet::ParseError, "#{name} for callee of function 'secret()' contains '/' (#{sth}). this is not allowed."
  end

  if not (sth =~ /^[.]*$/).nil?
    raise Puppet::ParseError, "#{name} for callee of function 'secret()' contains only dots ('.') (#{sth}). this is not allowed."
  end
end

def retrieve_secret callee, secretid
  # do the secret defining action here...
end