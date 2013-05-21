require 'spec_helper'
require 'rspec-puppet'
require 'puppet/file_serving/configuration'
require 'fileutils'

describe 'secret' do
  include RSpec::Puppet::Support

  # since let doesn't seem to work here
  #     let(:node) { 'spec.ops' }
  # instead pull in the fqdn manually:
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  it "should exist" do
    Puppet::Parser::Functions.function("secret").should == "function_secret"
  end

  describe "secret called by the client" do

    # make sure to bootstrap whatever environment we need
    before :each do
      scope.expects(:lookupvar).with("fqdn").returns("spec.ops")

      base_dir = "/tmp/secrets"
      FileUtils::rm_rf base_dir

      # mockup our configuration
      # mount to puppet:///secrets  ==>  /tmp/secrets/%H
      conf = Puppet::FileServing::Configuration.configuration
      mount = Puppet::FileServing::Mount::File.new "secrets"
      mount.path = "#{base_dir}/%H"
      conf.stubs(:mounts).returns("secrets" => mount)
    end

    it 'should be callable without parameters' do
      scope.function_secret([]).should eq('puppet:///secrets/default')
    end

  end

end
