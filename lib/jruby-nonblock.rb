require 'socket'

if defined? JRUBY_VERSION
  require 'java'
  require 'jruby-nonblock_ext'
  org.zomg.NonblockPatch.new.load(JRuby.runtime, false)
end