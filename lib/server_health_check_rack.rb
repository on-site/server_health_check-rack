require "server_health_check_rack/version"

module ServerHealthCheckRack
  autoload :Checks,     "server_health_check_rack/checks"
  autoload :Middleware, "server_health_check_rack/middleware"
end
