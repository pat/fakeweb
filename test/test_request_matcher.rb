require File.join(File.dirname(__FILE__), "test_helper")

class TestRequestMatcher < Test::Unit::TestCase
  def setup
    FakeWeb.clean_registry
    FakeWeb.clear_requests
    FakeWeb.ignore_query_params = false
  end
  
  def test_should_match_with_any_method
    FakeWeb.register_uri(:get, 'http://example.com/', :string => 'foo')
    open('http://example.com/')
    matcher = FakeWeb::RequestMatcher.new('http://example.com/')
    assert matcher.matches?(FakeWeb)
  end
  
  def test_should_match_with_specific_method
    FakeWeb.register_uri(:get, 'http://example.com/', :string => 'foo')
    open('http://example.com/')
    matcher = FakeWeb::RequestMatcher.new(:get, 'http://example.com/')
    assert matcher.matches?(FakeWeb)
  end
  
  def test_should_not_match
    FakeWeb.register_uri('http://example.com/one', :string => 'foo')
    open('http://example.com/one')
    matcher = FakeWeb::RequestMatcher.new('http://example.com/two')
    assert !matcher.matches?(FakeWeb)
  end
  
  def test_should_match_with_ignored_query_params
    FakeWeb.ignore_query_params = true
    FakeWeb.register_uri('http://example.com/', :string => 'foo')
    open('http://example.com/?a=1&b=2')
    matcher = FakeWeb::RequestMatcher.new('http://example.com/')
    assert matcher.matches?(FakeWeb)
  end
  
  def test_should_not_match_when_not_ignoring_query_params
    FakeWeb.ignore_query_params = false
    FakeWeb.register_uri('http://example.com/',         :string => 'foo')
    FakeWeb.register_uri('http://example.com/?a=1&b=2', :string => 'bar')
    open('http://example.com/?a=1&b=2')
    matcher = FakeWeb::RequestMatcher.new('http://example.com/')
    assert !matcher.matches?(FakeWeb)
  end
  
  def test_clearing_of_requests
    FakeWeb.register_uri(:get, 'http://example.com/', :string => 'foo')
    open('http://example.com/')
    matcher = FakeWeb::RequestMatcher.new(:get, 'http://example.com/')
    assert matcher.matches?(FakeWeb)
    
    FakeWeb.clear_requests
    assert !matcher.matches?(FakeWeb)
  end
end
