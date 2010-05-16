require File.join(File.dirname(__FILE__), 'spec_helper')

class User
  include Mongoid::Document

  field :name
  field :email, :accessible => true
  field :security_key

  attr_accessible :name
end

describe Mongoid, ".attr_accessible" do
  context "ordinary fields" do
    it "should be bulk updatable if named" do
      User.new(:name => 'Foo').name.should == 'Foo'
    end

    it "should be bulk updatable if declared with :accessible => true" do
      User.new(:email => 'foo@example.com').email.should == 'foo@example.com'
    end

    it "should not be bulk updatable otherwise" do
      user = User.new(:security_key => 'evil value')
      user.security_key.should be_nil
    end

    it "should always be settable using direct assignment" do
      user = User.new
      user.security_key = 'directly-assigned value'
      user.security_key.should == 'directly-assigned value'
    end

    it "should be settable using a block" do
      user = User.new {|u| u.security_key = 'block-assigned value' }
      user.security_key.should == 'block-assigned value'
    end
  end

  # it "should allow either strings or symbols"
  # it "should combine multiple declarations"
  # context "other setters"
  # context "associations"
  # context "classes without attr_accessible"
end
