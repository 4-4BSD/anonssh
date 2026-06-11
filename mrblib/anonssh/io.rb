module AnonSSH
  module IO
    ##
    # @return [String]
    # @return [void]
    def usage!
      error! <<~USAGE
        usage:
          anonssh <command> [options]

        commands:
          bootstrap  bootstrap a new jail
          serve      serve a program in a jail
      USAGE
    end

    ##
    # @param [String] message
    # @return [void]
    def error!(message)
      say(message, $stderr)
      exit(1)
    end

    ##
    # @param [String] message
    # @param [IO] io
    # @return [void]
    def say(message, io = $stdout)
      io.puts "anonssh: #{message}"
    end
  end
end
