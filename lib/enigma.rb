require 'rubygems'
require 'bundler/setup'
require 'rack'
require 'rack/test'

module Enigma
  SIGNATURE_HEADER  = "X_ENIGMA_SIGNATURE"

  extend self

  def self.server_key=(server_key)
    @server_key = server_key
  end

  def self.server_key
    @server_key
  end

  def signature(method, path, payload)
    message = [method, path, payload].map(&:to_s).inject(&:+)

    digest = OpenSSL::Digest::Digest.new("sha512")
    OpenSSL::HMAC.hexdigest(digest, self.server_key, message).to_s
  end

  def matches?(actual_signature, method, path, payload)
    matched = true
    expected_signature = self.signature(method, path, payload)
    expected_signature.each_char.zip(actual_signature.to_s.each_char).each do |expected, actual|
      matched = false if expected != actual
    end

    matched
  end
end
