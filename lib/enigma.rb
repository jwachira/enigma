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

	class Client 
		def initialize(options)
			@host        = options[:host] || 'localhost'
			@port        = options[:port] || 80
			@ssl         = options[:ssl]  || false
			@certificate = options[:certificate]
		end

		attr_reader :host, :port, :ssl, :certificate, :version

		HTTP_METHODS = [:get, :post, :put, :delete]
		HTTP_METHODS.each do |method|
			define_method(method) do |path, *args|
				payload = args.first
				execute method, path, payload
			end
		end

		def http
			base = "#{ssl ? "https" : "http"}://#{host}:#{port}"
			Class.new do
				include HTTParty
				base_uri base
			end
		end

		def execute(method, path, payload)
			response = http.send(method, path,
													 :headers => headers(method, path, payload),
													 :body => payload,
													 :timeout => TIMEOUT
													)

													response.body
		end

		TIMEOUT = 60 * 5

		private

		def headers(method, url, payload)
			{Enigma::SIGNATURE_HEADER =>
				Enigma.signature(method, url, payload)
			}
		end

		def scheme
			@ssl ? 'https' : 'http'
		end

		def base_url
			"#{scheme}://#{host}:#{port}"
		end
	end
end
