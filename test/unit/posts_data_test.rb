require 'test_helper'

class PostsDataTests < Test::Unit::TestCase

  def setup
    @url = 'http://example.com'
    @gateway = SimpleTestGateway.new
    @ok = stub(:body => '', :code => '200', :message => 'OK')
    @error = stub(:code => 500, :message => 'Internal Server Error', :body => 'failure')
  end
  
  def teardown
    SimpleTestGateway.retry_safe = false
  end
  
  def test_single_successful_post
    ActiveUtils::Connection.any_instance.expects(:request).returns(@ok)
    
    assert_nothing_raised do
      @gateway.ssl_post(@url, '') 
    end
  end
  
  def test_multiple_successful_posts
    ActiveUtils::Connection.any_instance.expects(:request).times(2).returns(@ok, @ok)
    
    assert_nothing_raised do
      @gateway.ssl_post(@url, '')
      @gateway.ssl_post(@url, '') 
    end
  end

  def test_500_response_during_request_raises_client_error
    ActiveUtils::Connection.any_instance.expects(:request).returns(@error)
    assert_raises(ActiveUtils::ResponseError) do
      @gateway.ssl_post('', {})
    end
  end

  def test_successful_raw_request
    ActiveUtils::Connection.any_instance.expects(:request).returns(@ok)
    assert_equal @ok, @gateway.raw_ssl_request(:post, @url, '')
  end

  def test_setting_ssl_strict_outside_class_definition
    assert_equal SimpleTestGateway.ssl_strict, SubclassGateway.ssl_strict
    SimpleTestGateway.ssl_strict = !SimpleTestGateway.ssl_strict
    assert_equal SimpleTestGateway.ssl_strict, SubclassGateway.ssl_strict
  end

  def test_setting_timeouts
    @gateway.class.open_timeout = 50
    @gateway.class.read_timeout = 37
    ActiveUtils::Connection.any_instance.expects(:request).returns(@ok)
    ActiveUtils::Connection.any_instance.expects(:open_timeout=).with(50)
    ActiveUtils::Connection.any_instance.expects(:read_timeout=).with(37)

    assert_nothing_raised do
      @gateway.ssl_post(@url, '')
    end
  end
end
