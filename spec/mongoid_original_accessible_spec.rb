require File.join(File.dirname(__FILE__), 'spec_helper')

class Player
  include Mongoid::Document

  field :email
  field :name, :accessible => true
  field :token, :accessible => false
end

describe Mongoid::Document, "class without attr_accessible" do
  it "should default to :accessible => true" do
    Player.new(:email => 'foo@example.com').email.should == 'foo@example.com'
  end

  it "should allow access when :accessible => true" do
    Player.new(:name => 'Foo').name.should == 'Foo'
  end

  it "should forbid access when :accessible => false" do
    Player.new(:token => 'evil value').token.should be_nil
  end
end
