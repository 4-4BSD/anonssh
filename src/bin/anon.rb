def main(argv)
  command = argv.shift
  case command
  when "bootstrap", "serve"
    pid = Process.spawn File.join(Anon.libexec, command), *argv
    Process.waitpid2(pid)
  else Anon.usage!
  end
end
main(ARGV)
