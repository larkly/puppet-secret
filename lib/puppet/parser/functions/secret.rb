
Puppet::Parser::Functions::newfunction(:secret, :type => :rvalue) do |vals|
  secretid = vals[0] || 'default'
  opts = vals[1] || {}
  opts['secrets_mount'] ||= 'secrets'

  # get the callee (secrets are saved based on fqdn)
  callee = lookupvar('::fqdn')
  raise Puppet::ParseError, "Can't find the FQDN of the client that is using secret(). aborting." if callee == :undefined

  Secret::ensure_secret callee, secretid, opts
  
  # point the client to his secret
  return "puppet:///#{opts['secrets_mount']}/#{secretid}"
end

module Secret
  class << self
    # global definitions, adjust to your liking
    MAX_SECRET_BYTES = 10*1024
    MIN_SECRET_BYTES = 1
    IDENTIFIER_ALPHABET =
      "abcdefghijklmnopqrstuvwxyz"+
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

    def ensure_secret callee, secretid, opts = {}
      # validate all user input
      validate callee, 'FQDN'
      validate secretid, 'secret ID'
      # do the secret defining action here...
      secrets_dir = get_secrets_dir callee, opts["secrets_mount"] || "secrets"
      secret_file = File::join secrets_dir, secretid
      create_secret secret_file, opts if not File::exists? secret_file
    end

    def generate_secret opts = {}
      require 'securerandom'

      # how bytes in the secret
      method = opts['method'].to_s
      len = opts['length'].to_i
      if len > 0
        bytes = map_length_to_bytes len, method
      else
        bytes = ( opts['bytes'] || 128 ).to_i
      end

      # make sure we don't have too few or too many bytes
      if    bytes < MIN_SECRET_BYTES
        raise Puppet::ParseError, "secrets cannot have a length of less than #{MIN_SECRET_BYTES} bytes (you provided '#{opts['bytes']}'). aborting."
      elsif bytes > MAX_SECRET_BYTES
        raise Puppet::ParseError, "secrets cannot have a length of more than #{MAX_SECRET_BYTES} bytes (you provided '#{opts['bytes']}'). aborting."
      end

      generate_secret_for_method method, bytes, opts
    end


    private

    def validate sth, name
      if sth.to_s.empty?
        raise Puppet::ParseError, "#{name} for callee of function 'secret()' is empty. can't proceed without it."
      end

      if (sth =~ /^[^\/]*$/).nil?
        raise Puppet::ParseError, "#{name} for callee of function 'secret()' contains '/' (you provided '#{sth}'). this is not allowed."
      end

      if not (sth =~ /^[.]+$/).nil?
        raise Puppet::ParseError, "#{name} for callee of function 'secret()' contains only dots ('.') (you provided '#{sth}'). this is not allowed."
      end
    end

    def create_secret secret_file, opts = {}
      secret = generate_secret opts
      write_secret_to_file secret, secret_file
    end

    def alphabet_secret bytes, alphabet
      raise Puppet::ParseError, "trying to encode with an empty alphabet. this is impossible." if alphabet.empty?

      res = ''
      n = alphabet.length
      length = bytes_to_length_for_cardinality bytes, n
      for i in (0..(length-1))
        res += alphabet[ SecureRandom.random_number(n), 1 ]
      end
      res
    end

    def y64_secret bytes
      SecureRandom.base64(bytes).gsub('+','.').gsub('/','_').gsub('=','-')
    end

    def ceph_secret
      if which("ceph-authtool").nil?
        raise Puppet::ParseError, "you must install ceph and have ceph-authtool executable in order to generate ceph secrets. aborting."
      else
        `ceph-authtool --gen-print-key`
      end
    end

    def length_to_bytes_for_cardinality length, cardinality
      ( length * (Math::log(cardinality)/Math::log(2)) / 8 ).floor
    end

    def bytes_to_length_for_cardinality bytes, cardinality
      ( bytes * 8 / (Math::log(cardinality)/Math::log(2)) ).ceil
    end

    def map_length_to_bytes length, method
      case method
      when 'base64'     ; length_to_bytes_for_cardinality length, 64
      when 'y64'        ; length_to_bytes_for_cardinality length, 64
      when 'alphabet'   ; length_to_bytes_for_cardinality length, IDENTIFIER_ALPHABET.length
      when 'default','' ; length
      else                raise Puppet::ParseError, "don't understand method '#{method}' for secret generation. aborting."
      end
    end

    def generate_secret_for_method method, bytes, opts = {}
      case method
      when 'base64'     ; SecureRandom.base64 bytes
      when 'y64'        ; y64_secret bytes
      when 'alphabet'   ; alphabet_secret bytes, IDENTIFIER_ALPHABET
      when 'default','' ; SecureRandom.random_bytes bytes
      else                raise Puppet::ParseError, "don't understand method '#{opts['method']}' for secret generation. aborting."
      end
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

    # determine if a command exists:
    # http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
    def which cmd
      exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
      ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
        exts.each { |ext|
          exe = File.join(path, "#{cmd}#{ext}")
          return exe if File.executable? exe
        }
      end
      return nil
    end

  end
end