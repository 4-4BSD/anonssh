def main(argv)
  path, binary, user = AnonSSH.parse(:bootstrap, argv)
  shlibs = ["/lib/libgcc_s.so.1", "/libexec/ld-elf.so.1"]
  binaries = ["/bin/sh",
              "/usr/sbin/sshd",
              "/usr/libexec/sshd-session",
              "/usr/libexec/sshd-auth",
              binary]

  if path.nil? || binary.nil?
    AnonSSH.error! "bootstrap requires -p PATH and -b BINARY"
  elsif !File.exist?(path)
    AnonSSH.error! "#{path} does not exist"
  elsif !File.exist?(binary)
    AnonSSH.error! "#{binary} does not exist"
  end

  AnonSSH.templates.each do |file|
    template = File.read(file)
    template.gsub!("%%USER%%", user)
    template.gsub!("%%BINARY%%", "/bin/#{File.basename(binary)}")
    dirname, filename = File.dirname(file), File.basename(file, ".tt")
    dest = File.join(dirname, filename)
    File.open(dest, "w") { _1.write(template) }
  end

  AnonSSH.tree.each do |dir|
    leaf = File.join(path, dir)
    AnonSSH.say "mkdir #{leaf}"
    command = AnonSSH.mkdir_p(leaf)
    if command.failure?
      AnonSSH.error!(command.stderr)
    end
  end

  src, dest = File.join(AnonSSH.share, "etc", "master.passwd"),
              File.join(path, "etc", "master.passwd")
  AnonSSH.say "cp #{src} #{dest}"
  command =  AnonSSH.cp(src, dest)
  if command.failure?
    AnonSSH.error!(command.stderr)
  end

  AnonSSH.etc.each do |src|
    src, dest = src, File.join(path, File.dirname(src).sub(AnonSSH.share, ''))
    command = AnonSSH.cp(src, dest)
    AnonSSH.say "cp #{src} #{dest}"
    if command.failure?
      AnonSSH.error!(command.stderr)
    end
  end

  dest = File.join(path, "/etc/master.passwd")
  AnonSSH.say "pwd_mkdb #{dest}"
  command = AnonSSH.pwd_mkdb(dest)
  if command.failure?
    AnonSSH.error!(command.stderr)
  end

  AnonSSH.say "discover shared libs"
  seen = {}
  binaries.each do |file|
    command = Command.new("ldd", "-a", file)
    if command.success?
      command.stdout.each_line do |line|
        _, other = line.split("=>")
        next unless other
        match, = other.split(" ")
        next unless match && match.start_with?("/")
        next if seen[match]
        seen[match] = true
        shlibs << match
      end
    else
      AnonSSH.error!(command.stderr)
    end
  end

  [*binaries, *shlibs].each do |file|
    target = (file == binary ? File.join("/bin", File.basename(file)) : file)
    src, dest = file, File.join(path, target)
    command = AnonSSH.mkdir_p(File.dirname(dest))
    if command.failure?
      AnonSSH.error!(command.stderr)
    end
    AnonSSH.say "#{src} -> #{dest}"
    command = AnonSSH.cp(src, dest)
    if command.failure?
      AnonSSH.error!(command.stderr)
    end
  end

  AnonSSH.say "create linker hints"
  command = AnonSSH.ldconfig(path)
  if command.failure?
    AnonSSH.error!(command.stderr)
  end

  AnonSSH.say "create SSH host keys"
  command = AnonSSH.ssh_keygen(path)
  if command.failure?
    AnonSSH.error!(command.stderr)
  end
end
main(ARGV)
