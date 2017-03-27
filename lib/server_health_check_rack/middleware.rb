module ServerHealthCheckRack
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      if ServerHealthCheckRack::Config.path?(env["PATH_INFO"])
        check = health_check(env["PATH_INFO"])
        [check.http_status, response_headers, [check.to_json]]
      else
        @app.call(env)
      end
    end

    private

    def health_check(rack_path_info)
      checks = ServerHealthCheckRack::Config.path_to_health_checks(rack_path_info)

      if checks == :all
        ServerHealthCheckRack::HealthCheck.all
      else
        ServerHealthCheckRack::HealthCheck.new(*checks)
      end
    end

    def response_headers
      {
        "Cache-Control" => "max-age=0, private, must-revalidate",
        "Content-Type" => "application/json"
      }
    end
  end
end
