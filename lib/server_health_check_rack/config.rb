module ServerHealthCheckRack
  class Config
    class << self
      attr_accessor :logger

      def path=(value)
        @path = value
        @path.sub!(/\/\z/, "") if @path
      end

      def path
        @path ||= "/health"
      end

      def path?(rack_path_info)
        return false unless rack_path_info.start_with?(path)
        rack_path_info =~ /\A#{Regexp.quote(path)}(?:[\/?]|\z)/
      end

      def path_to_health_checks(rack_path_info)
        raise ArgumentError, "Invalid health check path: #{rack_path_info}" unless path?(rack_path_info)
        rack_path_info = rack_path_info.sub(/\?.*/, "")
        rack_path_info.sub!(/\/\z/, "")
        return :all if rack_path_info == path
        [rack_path_info[/\/([^\/]*)\z/, 1]]
      end
    end
  end
end
