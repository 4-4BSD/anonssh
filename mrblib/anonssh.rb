module AnonSSH
  extend AnonSSH::IO
  extend AnonSSH::Commands

  ##
  # @return [Array<String>]
  def self.tree
    [
      "/etc", "/etc/ssh", "/etc/ssl", "/root", "/tmp",
      "/lib", "/libexec", "/sbin", "/bin", "/dev", "/var",
      "/usr", "/usr/share", "/usr/libexec", "/usr/lib",
      "/usr/include", "/usr/bin", "/usr/sbin", "/usr/local",
      "/usr/local/lib", "/var/run", "/var/empty"
    ]
  end

  ##
  # @return [Array<String>]
  def self.templates
    [
      File.join(AnonSSH.share, "etc", "group.tt"),
      File.join(AnonSSH.share, "etc", "master.passwd.tt"),
      File.join(AnonSSH.share, "etc", "ssh", "sshd_config.tt")
    ]
  end

  ##
  # @return [Array<String>]
  def self.etc
    [
      File.join("/etc", "ssl", "certs"),
      File.join("/etc", "ssl", "cert.pem"),
      File.join("/etc", "resolv.conf"),
      File.join(share, "etc", "group"),
      File.join(share, "etc", "ssh", "sshd_config")
    ]
  end

  ##
  # @param [Array<String>] argv
  # @return [Array<String, String>]
  def self.parse(command, argv)
    case command
    when :bootstrap
      while option = argv.shift
        case option
        when "-p" then path = argv.shift
        when "-b" then binary = argv.shift
        when "-u" then user = argv.shift
        else error!("unknown option: #{option}")
        end
      end
      [path, binary, user || "anonssh"]
    when :serve
      while option = argv.shift
        case option
        when "-n" then name = argv.shift
        when "-p" then path = argv.shift
        else error!("unknown option: #{option}")
        end
      end
      [name, path]
    end
  end

  ##
  # @return [String]
  def self.libexec
    rel = File.join File.dirname($0), "..", "libexec", "anonssh"
    File.realpath(rel)
  rescue Errno::ENOENT
    File.join(ENV["PREFIX"] || "/usr/local", "libexec", "anonssh")
  end

  ##
  # @return [String]
  def self.share
    rel = File.join File.dirname(__FILE__), "..", "share", "anonssh"
    File.realpath(rel)
  rescue Errno::ENOENT
    File.join(ENV["PREFIX"] || "/usr/local", "share", "anonssh")
  end
end
