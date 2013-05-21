require 'puppet'
require 'minitest/autorun'
require_relative '../../lib/puppet/parser/functions/secret'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

describe Secret do
  describe '.generate_secret' do

    it 'should have a default length of 128 bytes' do
      res = Secret::generate_secret
      res.length.should eq(128)
    end

    it 'should generate random binary' do
    end

    it 'should generate base64 secret' do
    end

    it 'should generate y64 secret' do
    end

    it 'should generate alphabet-based secret' do
    end

  end
end
