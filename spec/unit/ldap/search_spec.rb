# -*- ruby encoding: utf-8 -*-

describe Net::LDAP, "search method" do
  class FakeConnection
    def search(args)
      OpenStruct.new(:result_code => 1, :message => "error", :success? => false)
    end
  end

  before(:each) do
    @service = MockInstrumentationService.new
    @connection = Net::LDAP.new :instrumentation_service => @service
    @connection.instance_variable_set(:@open_connection, FakeConnection.new)
  end

  context "when :return_result => true" do
    it "should return nil upon error" do
      result_set = @connection.search(:return_result => true)
      result_set.should be_nil
    end
  end

  context "when :return_result => false" do
    it "should return false upon error" do
      result = @connection.search(:return_result => false)
      result.should == false
    end
  end

  context "When :return_result is not given" do
    it "should return nil upon error" do
      result_set = @connection.search
      result_set.should be_nil
    end
  end

  context "when instrumentation_service is configured" do
    it "should publish a search.net_ldap event" do
      events = @service.subscribe "search.net_ldap"

      @connection.search :filter => "test"

      payload, result = events.pop
      payload.should have_key(:result)
      payload.should have_key(:filter)
      payload[:filter].should == "test"
    end
  end
end
