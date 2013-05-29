begin
  require 'puppetlabs_spec_helper/rake_tasks'
  require 'puppet'
rescue LoadError
  stderr 'Please install all dependencies before running rake!'
  exit 1
end

require "rake/testtask"
Rake::TestTask.new do |t|
  t.pattern = "spec/classes/*_spec.rb"
end

task default: [:clean, :spec]
