def main(argv)
  path, binary, user = Anon.parse(:bootstrap, argv)
  shlibs = ["/lib/libgcc_s.so.1", "/libexec/ld-elf.so.1"]
  binaries = ["/bin/sh",
              "/usr/sbin/sshd",
              "/usr/libexec/sshd-session",
              "/usr/libexec/sshd-auth",
              binary]

  if path.nil? || binary.nil?
    Anon.error! "bootstrap requires -p PATH and -b BINARY"
  elsif !File.exist?(path)
    Anon.error! "#{path} does not exist"
  elsif !File.exist?(binary)
    Anon.error! "#{binary} does not exist"
  end

  Anon.templates.each do |file|
    template = File.read(file)
    template.gsub!("%%USER%%", user)
    template.gsub!("%%BINARY%%", "/bin/#{File.basename(binary)}")
    dirname, filename = File.dirname(file), File.basename(file, ".tt")
    dest = File.join(dirname, filename)
    File.open(dest, "w") { _1.write(template) }
  end

  Anon.tree.each do |dir|
    leaf = File.join(path, dir)
    Anon.say "mkdir #{leaf}"
    command = Anon.mkdir_p(leaf)
    if command.failure?
      Anon.error!(command.stderr)
    end
  end

  src, dest = File.join(Anon.share, "etc", "master.passwd"),
              File.join(path, "etc", "master.passwd")
  Anon.say "cp #{src} #{dest}"
  command =  Anon.cp(src, dest)
  if command.failure?
    Anon.error!(command.stderr)
  end

  Anon.etc.each do |src|
    src, dest = src, File.join(path, File.dirname(src).sub(Anon.share, ''))
    command = Anon.cp(src, dest)
    Anon.say "cp #{src} #{dest}"
    if command.failure?
      Anon.error!(command.stderr)
    end
  end

  dest = File.join(path, "/etc/master.passwd")
  Anon.say "pwd_mkdb #{dest}"
  command = Anon.pwd_mkdb(dest)
  if command.failure?
    Anon.error!(command.stderr)
  end

  Anon.say "discover shared libs"
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
      Anon.error!(command.stderr)
    end
  end

  [*binaries, *shlibs].each do |file|
    target = (file == binary ? File.join("/bin", File.basename(file)) : file)
    src, dest = file, File.join(path, target)
    command = Anon.mkdir_p(File.dirname(dest))
    if command.failure?
      Anon.error!(command.stderr)
    end
    Anon.say "#{src} -> #{dest}"
    command = Anon.cp(src, dest)
    if command.failure?
      Anon.error!(command.stderr)
    end
  end

  Anon.say "create linker hints"
  command = Anon.ldconfig(path)
  if command.failure?
    Anon.error!(command.stderr)
  end

  Anon.say "create SSH host keys"
  command = Anon.ssh_keygen(path)
  if command.failure?
    Anon.error!(command.stderr)
  end
end
main(ARGV)
