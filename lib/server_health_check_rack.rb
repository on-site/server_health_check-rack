require "server_health_check_rack/version"

module ServerHealthCheckRack
  autoload :Checks,      "server_health_check_rack/checks"
  autoload :Config,      "server_health_check_rack/config"
  autoload :HealthCheck, "server_health_check_rack/health_check"
  autoload :Middleware,  "server_health_check_rack/middleware"
end
