require "test_helper"

class ServerHealthCheckRack::ConfigTest < Minitest::Test
  def setup
    ServerHealthCheckRack::Config.instance_variable_set(:@path, nil)
  end

  def test_path_can_be_customized
    assert_equal "/health", ServerHealthCheckRack::Config.path
    ServerHealthCheckRack::Config.path = "/check"
    assert_equal "/check", ServerHealthCheckRack::Config.path
    ServerHealthCheckRack::Config.path = "/nested/check"
    assert_equal "/nested/check", ServerHealthCheckRack::Config.path
  end

  def test_path_can_be_customized_with_trailing_slash
    assert_equal "/health", ServerHealthCheckRack::Config.path
    ServerHealthCheckRack::Config.path = "/check/"
    assert_equal "/check", ServerHealthCheckRack::Config.path
    ServerHealthCheckRack::Config.path = "/nested/check/"
    assert_equal "/nested/check", ServerHealthCheckRack::Config.path
  end

  def test_path_with_root_path
    assert ServerHealthCheckRack::Config.path?("/health")
    assert ServerHealthCheckRack::Config.path?("/health/")
    refute ServerHealthCheckRack::Config.path?("/other")
    refute ServerHealthCheckRack::Config.path?("/health_check")
    refute ServerHealthCheckRack::Config.path?("/nested/health")
    refute ServerHealthCheckRack::Config.path?("/health_check/")
    refute ServerHealthCheckRack::Config.path?("/health_check/health")
  end

  def test_path_with_nested_path
    assert ServerHealthCheckRack::Config.path?("/health/aws")
    assert ServerHealthCheckRack::Config.path?("/health/redis")
    refute ServerHealthCheckRack::Config.path?("/other/redis")
    refute ServerHealthCheckRack::Config.path?("/health_check/redis")
  end

  def test_path_with_root_path_with_query_string
    assert ServerHealthCheckRack::Config.path?("/health?query=string")
    assert ServerHealthCheckRack::Config.path?("/health/?query=string")
    refute ServerHealthCheckRack::Config.path?("/other?query=string")
    refute ServerHealthCheckRack::Config.path?("/health_check?query=string")
    refute ServerHealthCheckRack::Config.path?("/health_check/?query=string")
  end

  def test_path_with_nested_path_with_query_string
    assert ServerHealthCheckRack::Config.path?("/health/aws?query=string")
    assert ServerHealthCheckRack::Config.path?("/health/redis?query=string")
    refute ServerHealthCheckRack::Config.path?("/other/redis?query=string")
    refute ServerHealthCheckRack::Config.path?("/health_check/redis?query=string")
  end

  def test_path_with_customized_path
    ServerHealthCheckRack::Config.path = "/check"
    assert ServerHealthCheckRack::Config.path?("/check")
    assert ServerHealthCheckRack::Config.path?("/check/")
    assert ServerHealthCheckRack::Config.path?("/check?query=string")
    assert ServerHealthCheckRack::Config.path?("/check/?query=string")
    assert ServerHealthCheckRack::Config.path?("/check/aws")
    assert ServerHealthCheckRack::Config.path?("/check/aws?query=string")
    refute ServerHealthCheckRack::Config.path?("/other")
    refute ServerHealthCheckRack::Config.path?("/nested/check")
    refute ServerHealthCheckRack::Config.path?("/check_health")
    refute ServerHealthCheckRack::Config.path?("/check_health/")
    refute ServerHealthCheckRack::Config.path?("/check_health?query=string")
    refute ServerHealthCheckRack::Config.path?("/check_health/check")
  end

  def test_path_with_nested_customized_path
    ServerHealthCheckRack::Config.path = "/nested/check"
    assert ServerHealthCheckRack::Config.path?("/nested/check")
    assert ServerHealthCheckRack::Config.path?("/nested/check/")
    assert ServerHealthCheckRack::Config.path?("/nested/check?query=string")
    assert ServerHealthCheckRack::Config.path?("/nested/check/?query=string")
    assert ServerHealthCheckRack::Config.path?("/nested/check/aws")
    assert ServerHealthCheckRack::Config.path?("/nested/check/aws?query=string")
    refute ServerHealthCheckRack::Config.path?("/some/nested/check")
    refute ServerHealthCheckRack::Config.path?("/check_health")
    refute ServerHealthCheckRack::Config.path?("/nested/check_health/")
    refute ServerHealthCheckRack::Config.path?("/nested/check_health/nested/check")
  end

  def test_path_to_health_checks_with_root_path
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/health")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/health/")
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/other") }
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/nested/health") }
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/health_check") }
  end

  def test_path_to_health_checks_with_nested_path
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/health/aws")
    assert_equal ["redis"], ServerHealthCheckRack::Config.path_to_health_checks("/health/redis")
  end

  def test_path_to_health_checks_with_root_path_with_query_string
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/health?query=string")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/health/?query=string")
  end

  def test_path_to_health_checks_with_nested_path_with_query_string
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/health/aws?query=string")
    assert_equal ["redis"], ServerHealthCheckRack::Config.path_to_health_checks("/health/redis?query=string")
  end

  def test_path_to_health_checks_with_customized_path
    ServerHealthCheckRack::Config.path = "/check"
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/check")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/check/")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/check?query=string")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/check/?query=string")
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/check/aws")
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/check/aws?query=string")
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/nested/check") }
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/check_health") }
  end

  def test_path_to_health_checks_with_nested_customized_path
    ServerHealthCheckRack::Config.path = "/nested/check"
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/nested/check")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/nested/check/")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/nested/check?query=string")
    assert_equal :all, ServerHealthCheckRack::Config.path_to_health_checks("/nested/check/?query=string")
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/nested/check/aws")
    assert_equal ["aws"], ServerHealthCheckRack::Config.path_to_health_checks("/nested/check/aws?query=string")
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/other") }
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/nested/check_health") }
    assert_raises(ArgumentError) { ServerHealthCheckRack::Config.path_to_health_checks("/some/nested/check") }
  end
end
