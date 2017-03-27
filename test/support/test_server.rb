require "json"
require "net/http"
require "rack"
require "uri"
require "webrick"

class TestServer
  class Response
    attr_reader :status, :body

    def initialize(status, body)
      @status = status.to_i
      @body = body
    end

    def json
      JSON.parse(body)
    end
  end

  def initialize
    @started = false
    @stopped = false
    @port = TestServer.next_port
  end

  def self.next_port
    @next_port ||= 10_000
    @next_port += 1
  end

  def request(path)
    response = Net::HTTP.get_response URI("http://localhost:#{@port}#{path}")
    TestServer::Response.new response.code, response.body
  end

  def response
    "This is the test server"
  end

  def start
    raise "Already started!" if @started
    @started = true

    @thread = Thread.new do
      Rack::Handler::WEBrick.run(app, Port: @port)
    end

    ServerCheck.new(@port).wait
  end

  def stop
    return if @stopped
    @stopped = true
    Rack::Handler::WEBrick.shutdown
  end

  def join
    raise "Only join if stopping!" unless @stopped
    puts "WARNING: SimpleServer is not stopping!" unless @thread.join(10)
  end

  private

  def app
    @app ||=
      begin
        test_server = self

        Rack::Builder.app do
          use ServerHealthCheckRack::Middleware
          run lambda { |env| ["200", { "Content-Type" => "text/html" }, [test_server.response.to_json]] }
        end
      end
  end
end
