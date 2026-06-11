module Anon
  extend Anon::IO
  extend Anon::Commands

  ##
  # @return [Array<String>]
  def self.tree
    [
      "/etc", "/etc/rc.d", "/etc/ssh", "/root", "/tmp",
      "/lib", "/libexec", "/sbin", "/bin", "/dev", "/var",
      "/usr", "/usr/share", "/usr/libexec", "/usr/lib",
      "/usr/include", "/usr/bin", "/usr/sbin"
    ]
  end

  ##
  # @return [Array<String>]
  def self.templates
    [
      File.join(Anon.share, "etc", "group.tt"),
      File.join(Anon.share, "etc", "master.passwd.tt"),
      File.join(Anon.share, "etc", "ssh", "sshd_config.tt")
    ]
  end

  ##
  # @return [Array<String>]
  def self.etc
    [
      File.join(share, "etc", "group"),
      File.join(share, "etc", "ssh", "sshd_config"),
      File.join(share, "etc", "rc.conf")
    ]
  end

  ##
  # @return [Array<String>]
  def self.bootfiles
    ["/etc/rc", "/etc/rc.subr", "/etc/rc.d/sshd"]
  end

  ##
  # @param [Array<String>] argv
  # @return [Array<String, String>]
  def self.parse(command, argv)
    while option = argv.shift
      case command
      when :bootstrap
        case option
        when "-p" then path = argv.shift
        when "-b" then binary = argv.shift
        when "-u" then user = argv.shift
        else error!("unknown option: #{option}")
        end
      end
    end
    [path, binary, user || "anon"]
  end

  ##
  # @return [String]
  def self.libexec
    rel = File.join File.dirname($0), "..", "libexec", "anon"
    File.realpath(rel)
  end

  ##
  # @return [String]
  def self.share
    rel = File.join File.dirname(__FILE__), "..", "share", "anon"
    File.realpath(rel)
  end
end
