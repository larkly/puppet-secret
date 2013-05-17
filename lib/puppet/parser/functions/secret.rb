
Puppet::Parser::Functions::newfunction(:secret, :type => :rvalue) do |vals|
  secretname = vals[0]
  
  return "puppet:///secrets/secret"
end