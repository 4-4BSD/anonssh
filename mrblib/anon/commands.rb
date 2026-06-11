module Anon
  module Commands
    ##
    # @param [String] src
    # @param [String] dest
    # @return [Command]
    def cp(src, dest)
      argv = File.directory?(src) ? ["-R"] : []
      src = src[0..-2] if src.end_with?("/")
      Command
        .new("cp")
        .argv(*argv)
        .argv(src, dest)
    end

    ##
    # @param [String] masterpw
    # @return [Command]
    def pwd_mkdb(masterpw)
      Command
        .new("pwd_mkdb")
        .argv("-p")
        .argv("-d", File.dirname(masterpw))
        .argv(masterpw)
    end

    ##
    # @param [String] path
    # @return [Command]
    def ldconfig(path)
      Command
        .new("ldconfig")
        .argv("-f", File.join(path, "var", "run", "ld-elf.so.hints"))
        .argv("/lib")
        .argv("/usr/lib")
        .argv("/usr/local/lib")
    end

    ##
    # @param [String] path
    # @return [Command]
    def ssh_keygen(path)
      Command
        .new("ssh-keygen")
        .argv("-A")
        .argv("-f", path)
    end

    ##
    # @param [String] path
    # @return [Command]
    def mount_devfs(path)
      Command
        .new("mount")
        .argv("-t", "devfs")
        .argv("devfs")
        .argv(File.join(path, "dev"))
    end

    ##
    # @param [String] path
    # @param [String] set
    # @return [Command]
    def devfs_ruleset(path, set = "4")
      Command
        .new("devfs")
        .argv("-m", File.join(path, "dev"))
        .argv("ruleset")
        .argv(set)
    end

    ##
    # @param [String] path
    # @return [Command]
    def devfs_applyset(path)
      Command
        .new("devfs")
        .argv("-m", File.join(path, "dev"))
        .argv("rule")
        .argv("applyset")
    end

    ##
    # @param [String] path
    # @return [Command]
    def mkdir_p(path)
      Command
        .new("mkdir")
        .argv("-p", path)
    end
  end
end
