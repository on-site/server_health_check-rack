$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "server_health_check/rack"
require_relative "support/test_server"
require_relative "support/server_check"

require "minitest/autorun"
