if defined? JRUBY_VERSION
  require 'rake/javaextensiontask'
  Rake::JavaExtensionTask.new('jruby-nonblock_ext') do |ext|
    ext.ext_dir = 'ext'
  end
end