module Anon
  module IO
    ##
    # @return [String]
    # @return [void]
    def usage!
      error! <<~USAGE
        usage:
          anon <command> [options]

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
      io.puts "anon: #{message}"
    end
  end
end
