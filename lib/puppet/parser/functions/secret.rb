
Puppet::Parser::Functions::newfunction(:secret, :type => :rvalue) do |vals|
  secretid = vals[0] || 'default'
  opts = vals[1] || {}
  opts['secrets_mount'] ||= 'secrets'

  # get the callee (secrets are saved based on fqdn)
  callee = lookupvar('fqdn')

  # validate all user input
  validate callee, 'FQDN'
  validate secretid, 'secret ID'

  ensure_secret callee, secretid, opts
  
  # point the client to his secret
  return "puppet:///#{opts['secrets_mount']}/#{secretid}"
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

def ensure_secret callee, secretid, opts = {}
  # do the secret defining action here...
  secrets_dir = get_secrets_dir callee
  #f = File::join( secrets_dir, callee, secretid )
end

def get_secrets_dir node, mount_point = "secrets"
  require 'puppet/util/inifile'
  require 'fileutils'

  fileserver = Puppet::FileServing::Configuration.configuration
  dir_obj = fileserver.find_mount mount_point, nil

  # make sure the mountpoint actually exists
  if dir_obj.nil?
    raise Puppet::ParseError,
      "can't find a folder mounted to '#{mount_point}'. "+
      "make sure you have a folder configured in fileserving for mountpoint '#{mount_point}'. "+
      "can't generate secret without a secret folder."
  end

  # get the specific folder for this callee
  dir = dir_obj.path node

  # make sure the secret folder exists
  if not File::exists? dir
    FileUtils::mkdir_p dir
  end

  # make sure it is a folder
  if not File::directory? dir
    raise Puppet::ParseError,
      "secret path for mount point '#{mount_point}' is not a directory (#{dir}). "+
      "can't generate secret without a secret folder."
  end

  dir
end