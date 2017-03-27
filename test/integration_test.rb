require "test_helper"

class IntegrationTest < Minitest::Test
  def setup
    ServerHealthCheckRack::Checks.instance_variable_set(:@checks, nil)
    ServerHealthCheckRack::Config.instance_variable_set(:@path, nil)
    @server = TestServer.new
    @server.start
  end

  def teardown
    @server.stop
    @server.join
  end

  def test_health_with_no_checks_fails
    assert_response "/health", 500, /Please configure server_health_check-rack/
  end

  def test_non_health_check_doesnt_interfere
    assert_equal @server.response, @server.request("/some/path").json
    assert_equal @server.response, @server.request("/health_check").json
    assert_equal @server.response, @server.request("/nested/health").json
  end

  def test_health_check_for_health_server_response_with_success
    ServerHealthCheckRack::Checks.check("example") { true }
    assert_response "/health", 200, example: "OK"
    assert_response "/health/example", 200, example: "OK"
  end

  def test_health_check_for_health_server_response_with_failure
    ServerHealthCheckRack::Checks.check("example") { false }
    assert_response "/health", 500, example: "Failed"
    assert_response "/health/example", 500, example: "Failed"
  end

  def test_customized_path_doesnt_interfere
    ServerHealthCheckRack::Config.path = "/nested/check"
    assert_equal @server.response, @server.request("/nested").json
    assert_equal @server.response, @server.request("/nested/check_health").json
    assert_equal @server.response, @server.request("/health").json
  end

  def test_customized_path_responds_to_path
    ServerHealthCheckRack::Config.path = "/nested/check"
    ServerHealthCheckRack::Checks.check("example_success") { true }
    ServerHealthCheckRack::Checks.check("example_failure") { false }
    assert_response "/nested/check", 500, example_success: "OK", example_failure: "Failed"
    assert_response "/nested/check/example_success", 200, example_success: "OK"
    assert_response "/nested/check/example_failure", 500, example_failure: "Failed"
  end

  def test_health_with_multiple_successful_checks
    ServerHealthCheckRack::Checks.check("foo") { true }
    ServerHealthCheckRack::Checks.check("bar") { true }
    assert_response "/health", 200, foo: "OK", bar: "OK"
  end

  def test_health_with_multiple_failed_checks
    ServerHealthCheckRack::Checks.check("example") { true }
    ServerHealthCheckRack::Checks.check("foo") { false }
    ServerHealthCheckRack::Checks.check("bar") { false }
    assert_response "/health", 500, example: "OK", foo: "Failed", bar: "Failed"
  end

  def test_health_with_multiple_error_checks
    ServerHealthCheckRack::Checks.check("example") { true }
    ServerHealthCheckRack::Checks.check("foo") { raise "This is the first error" }
    ServerHealthCheckRack::Checks.check("bar") { raise "This is the second error" }
    assert_response "/health", 500, example: "OK", foo: "This is the first error", bar: "This is the second error"
  end

  def test_health_with_mixed_error_and_failure_checks
    ServerHealthCheckRack::Checks.check("example") { true }
    ServerHealthCheckRack::Checks.check("foo") { false }
    ServerHealthCheckRack::Checks.check("bar") { raise "This is the second error" }
    assert_response "/health", 500, example: "OK", foo: "Failed", bar: "This is the second error"
  end

  def test_single_health_returns_just_the_requested_check
    ServerHealthCheckRack::Checks.check("example") { true }
    ServerHealthCheckRack::Checks.check("foo") { true }
    ServerHealthCheckRack::Checks.check("bar") { true }
    assert_response "/health/foo", 200, foo: "OK"
  end

  def test_single_health_doesnt_invoke_non_requested_checks
    bar_called = false
    ServerHealthCheckRack::Checks.check("example") { true }
    ServerHealthCheckRack::Checks.check("foo") { true }
    ServerHealthCheckRack::Checks.check("bar") { bar_called = true }
    assert_response "/health/foo", 200, foo: "OK"
    refute bar_called
  end

  private

  def assert_response(path, expected_status, expected_body)
    response = @server.request(path)
    assert_equal expected_status, response.status

    if expected_body.is_a?(Regexp)
      assert_match expected_body, response.body
    else
      assert_equal expected_response(expected_body), response.json
    end
  end

  def expected_response(hash)
    result = {}

    hash.each do |key, value|
      result[key.to_s] = value
    end

    { "status" => result }
  end
end
