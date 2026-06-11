def main(argv)
  command = argv.shift
  case command
  when "bootstrap", "serve"
    pid = Process.spawn File.join(AnonSSH.libexec, command), *argv
    Process.waitpid2(pid)
  else AnonSSH.usage!
  end
end
main(ARGV)
