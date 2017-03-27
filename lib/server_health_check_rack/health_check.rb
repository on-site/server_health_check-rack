require "server_health_check"
require "json"

module ServerHealthCheckRack
  class HealthCheck
    def initialize(*checks)
      @check = ServerHealthCheck.new(logger: ServerHealthCheckRack::Config.logger)
      ServerHealthCheckRack::Checks.apply_checks(@check, checks)
    end

    def self.all
      new(*ServerHealthCheckRack::Checks.all_checks)
    end

    def http_status
      if @check.ok?
        200
      else
        500
      end
    end

    def to_h
      {
        status: @check.results
      }
    end

    def to_json
      to_h.to_json
    end
  end
end
