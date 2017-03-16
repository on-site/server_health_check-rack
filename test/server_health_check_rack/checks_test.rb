require "test_helper"

class ServerHealthCheckRack::ChecksTest < Minitest::Test
  def setup
    ServerHealthCheckRack::Checks.instance_variable_set(:@checks, nil)
  end

  def test_redis_honors_cutom_redis_config
    mock = Minitest::Mock.new
    mock.expect(:redis!, nil, [{ host: "custom.host", port: 4242 }])
    ServerHealthCheckRack::Checks.check_redis!(host: "custom.host", port: 4242)
    ServerHealthCheckRack::Checks.apply_checks(mock, ["redis"])
    assert_mock(mock)
  end

  def test_aws_s3_honors_cutom_bucket
    mock = Minitest::Mock.new
    mock.expect(:aws_s3!, nil, ["custom.bucket"])
    ServerHealthCheckRack::Checks.check_aws_s3!("custom.bucket")
    ServerHealthCheckRack::Checks.apply_checks(mock, ["aws_s3"])
    assert_mock(mock)
  end
end
