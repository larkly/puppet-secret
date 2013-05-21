require 'puppet'
require 'minitest/autorun'
require_relative '../../lib/puppet/parser/functions/secret'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

describe Secret do
  describe '.generate_secret' do

    before do
      @test_chars = lambda{|res,alph| res.split('').find_all{|c| alph.include?(c)}.length == res.length}
      @base64 =   "+/0123456789=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      @y64 =      "._0123456789-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
      @alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    end

    it 'should have a default of binary with 128 bytes' do
      res = Secret::generate_secret
      res.length.should eq(128)
    end

    it 'should generate random binary' do
      Secret::generate_secret({'method'=>'default','bytes'=>200}).length.should eq(200)
    end

    it 'should generate base64 secret' do
      Secret::generate_secret({'method'=>'base64','bytes'=>10}).length.should eq(16)
      res = Secret::generate_secret({'method'=>'base64','bytes'=>10000})
      @test_chars.(res,@base64).should == true
    end

    it 'should generate y64 secret' do
      Secret::generate_secret({'method'=>'y64','bytes'=>10}).length.should eq(16)
      res = Secret::generate_secret({'method'=>'y64','bytes'=>10000})
      @test_chars.(res,@y64).should == true
    end

    it 'should generate alphabet-based secret' do
      Secret::generate_secret({'method'=>'alphabet','bytes'=>11}).length.should eq(16)
      res = Secret::generate_secret({'method'=>'alphabet','bytes'=>10000})
      @test_chars.(res,@alphabet).should == true
    end

  end
end
