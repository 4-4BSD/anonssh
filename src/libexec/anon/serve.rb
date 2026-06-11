def main(argv)
  name, path = Anon.parse(:serve, argv)
  if name.nil? || path.nil?
    Anon.error! "serve requires -n NAME and -p PATH"
  elsif !File.exist?(path)
    Anon.error! "#{path} does not exist"
  end

  command = Anon.mount_devfs(path)
  if command.failure?
    Anon.error!(command.stderr)
  end

  command = Anon.devfs_ruleset(path)
  if command.failure?
    Anon.error!(command.stderr)
  end

  command = Anon.devfs_applyset(path)
  if command.failure?
    Anon.error!(command.stderr)
  end

  jail = Jail.create(name:,path:,ip4: "inherit",devfs_ruleset: 4)
  jail.attach
  pid = Process.spawn("/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config")
  Process.waitpid(pid)
end
main(ARGV)
