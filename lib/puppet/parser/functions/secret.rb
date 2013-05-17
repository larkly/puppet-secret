
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
  secrets_dir = get_secrets_dir callee, opts["secrets_mount"] || "secrets"
  secret_file = File::join secrets_dir, secretid
  create_secret secret_file, opts if not File::exists? secret_file
end

def create_secret secret_file, opts = {}
  secret = generate_secret opts
  write_secret_to_file secret, secret_file
end

def generate_secret opts = {}
  require 'securerandom'
  bytes = opts['bytes'] || 128
  base64 = ( opts['base64'] || false ) == true

  (base64) ? SecureRandom.base64(bytes) : SecureRandom.random_bytes(bytes)
end

def write_secret_to_file secret, secret_file
  begin
    f = File.new secret_file, 'w'
    f.puts secret
    f.close
  rescue Errno::EACCES
    raise Puppet::ParserError,
        "could not write to secret file '#{secret_file}'. "+
        "check your permissions and make sure puppet has write/create access to the location. "+
        "can't generate secret without a secret folder."
  end
end

def get_secrets_dir node, mount_point
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
    begin
      FileUtils::mkdir_p dir
    rescue Errno::EACCES
      raise Puppet::ParserError,
        "could not create secret folder '#{dir}' for mount point '#{mount_point}'. "+
        "check your permissions and make sure puppet has write/create access to the location. "+
        "can't generate secret without a secret folder."
    end
  end

  # make sure it is a folder
  if not File::directory? dir
    raise Puppet::ParseError,
      "secret path for mount point '#{mount_point}' is not a directory (#{dir}). "+
      "can't generate secret without a secret folder."
  end

  dir
end