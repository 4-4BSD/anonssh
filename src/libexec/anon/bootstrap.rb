def main(argv)
  path, binary, user = Anon.parse(:bootstrap, argv)
  shlibs = []
  binaries = ["/bin/sh", "/usr/sbin/sshd", "/usr/bin/ssh-keygen", binary]

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

  [*Anon.bootfiles, *Anon.etc].each do |src|
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
  binaries.each do |file|
    command = Command.new("ldd", file)
    if command.success?
      command.stdout.each_line do |line|
        _, other = line.split("=>")
        next unless other
        match, = other.split(" ")
        shlibs << match if match
      end
    else
      Anon.error!(command.stderr)
    end
  end

  [*binaries, *shlibs].each do |file|
    target = (file == binary ? File.join("/bin", File.basename(file)) : file)
    src, dest = file, File.join(path, target)
    Anon.say "#{src} -> #{dest}"
    command = Anon.cp(src, dest)
    if command.failure?
      Anon.error!(command.stderr)
    end
  end
end
main(ARGV)
