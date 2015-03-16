require 'spec_helper'

describe HTTPStatus::Base, 'class inheritance' do

  before do
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:testing_status] = 9000
    @status_exception_class = HTTPStatus::TestingStatus
  end

  after do
    HTTPStatus.send :remove_const, 'TestingStatus'
  end

  it "should set the status symbol based on the class name" do
    @status_exception_class.status.should == :testing_status
  end

  it "should check Rack's status code list for the status code based on the class name" do
    Rack::Utils::SYMBOL_TO_STATUS_CODE.should_receive(:[]).with(:testing_status)
    @status_exception_class.status_code
  end

  it "should raise an exception when the class name does not correspond to a HTTP status code" do
    lambda { HTTPStatus::Nonsense }.should raise_error
  end
end

# Run some tests for different valid subclasses.
{ 'NotFound' => 404, 'Forbidden' => 403, 'PaymentRequired' => 402, 'InternalServerError' => 500}.each do |status_class, status_code|

  describe "HTTPStatus::#{status_class}" do
    it "should generate the HTTPStatus::#{status_class} class successfully" do
      lambda { HTTPStatus.const_get(status_class) }.should_not raise_error
    end

    it "should create a subclass of HTTPStatus::Base for the #{status_class.underscore.humanize.downcase} status" do
      HTTPStatus.const_get(status_class).ancestors.should include(HTTPStatus::Base)
    end

    it "should return the correct status code (#{status_code}) when using the class" do
      HTTPStatus.const_get(status_class).status_code.should == status_code
    end

    it "should return the correct status code (#{status_code}) when using the instance" do
      HTTPStatus.const_get(status_class).new.status_code.should == status_code
    end

    it "should update ActionPack's rescue responses look up table with the new HTTPStatus class" do
      rescue_responses = if ActionPack::VERSION::MAJOR == 3
        HTTPStatus::Railtie.config.action_dispatch.rescue_responses
      # rescue_responses = if defined?(ActionDispatch)
      #   ActionDispatch::ShowExceptions.rescue_responses
      else
        ActionController::Base.rescue_responses
      end

      rescue_responses.keys.should include("HTTPStatus::#{status_class}")
      rescue_responses["HTTPStatus::#{status_class}"].should == status_class.underscore.to_sym
    end
  end
end
