module Enigma
  module Spec
    class RackTestClient
      def initialize(app)
        @app = app
      end

      attr_reader :app

      def session
        Rack::Test::Session.new(Rack::MockSession.new(app))
      end

      def execute(opts)
        method = opts[:method]
        path = opts[:path]
        body = opts[:payload] || ""
        headers = opts[:headers].inject({}) {|_, (k, v)| _.merge(convert_header(k) => v) }

        rack_response = session.send(method, path, body, headers)

        OpenStruct.new :code => rack_response.status.to_i, :body => rack_response.body

      end

      [:get, :post, :put, :delete].each do |method|
        define_method(method) do |path, options|
          execute(
            :method => method,
            :path => path,
            :payload => options[:body],
            :headers => options[:headers]
          )
        end
      end

      private

      def convert_header(header)
        "HTTP_" + header.to_s.upcase.gsub("-", "_")
      end
    end
  end
end
