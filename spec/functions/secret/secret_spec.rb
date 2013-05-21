require 'spec_helper'
require 'rspec-puppet'
require 'puppet/file_serving/configuration'

describe 'secret' do
  include RSpec::Puppet::Support

  it "should exist" do
    Puppet::Parser::Functions.function("secret").should == "function_secret"
  end

end
