MRuby::Gem::Specification.new("anonssh") do |spec|
  spec.license = "0BSD"
  spec.authors = "0x1eef <0x1eef@hardenedbsd.org>"
  spec.version = "0.1.0"
  spec.description = "..."
  spec.add_dependency "mruby-command", github: "0x1eef/mruby-command", branch: "v0.2.0"
  spec.add_dependency "mruby-jail", github: "0x1eef/mruby-jail", branch: "v0.1.0.beta.1"
  spec.rbfiles = [
    File.join(__dir__, "mrblib", "anonssh", "io.rb"),
    File.join(__dir__, "mrblib", "anonssh", "commands.rb"),
    File.join(__dir__, "mrblib", "anonssh.rb")
  ].map { File.realpath(_1) }
end
