MRuby::Build.new("anonssh") do |conf|
  profile = ENV["BUILD"] || "base-dynamic"
  raise ArgumentError, "unknown BUILD=#{profile.inspect}" unless profile == "base-dynamic"

  conf.toolchain
  conf.gembox "default"
  conf.gem File.expand_path(__dir__)

  conf.cc.flags << "-Os -ffunction-sections -fdata-sections -DNDEBUG"
  conf.linker.flags << "-Wl,--gc-sections"
end
