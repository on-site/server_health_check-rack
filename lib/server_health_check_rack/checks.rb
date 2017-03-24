require "set"

module ServerHealthCheckRack
  class Checks
    class << self
      attr_accessor :logger

      def all_checks
        raise ArgumentError, "Please configure server_health_check-rails!" if @checks.nil?
        @checks.keys
      end

      def apply_checks(server_health_check, checks)
        raise ArgumentError, "Please configure server_health_check-rails!" if @checks.nil?
        checks = Set.new(checks)

        @checks.each do |name, check|
          next unless checks.include?(name)
          check.call(server_health_check)
        end
      end

      def check(name, &block)
        add_check name do |server_health_check|
          server_health_check.check!(name, &block)
        end
      end

      def check_active_record!
        add_check "active_record" do |server_health_check|
          server_health_check.active_record!
        end
      end

      def check_redis!(host: nil, port: 6379)
        add_check "redis" do |server_health_check|
          server_health_check.redis! host: host, port: port
        end
      end

      def check_aws_s3!(bucket = nil)
        add_check "aws_s3" do |server_health_check|
          server_health_check.aws_s3! bucket
        end
      end

      def check_aws_creds!
        add_check "aws_creds" do |server_health_check|
          server_health_check.aws_creds!
        end
      end

      private

      def add_check(name, &block)
        @checks ||= {}
        @checks[name] = block
      end
    end
  end
end
