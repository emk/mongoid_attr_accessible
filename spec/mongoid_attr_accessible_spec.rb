require File.join(File.dirname(__FILE__), 'spec_helper')

class User
  include Mongoid::Document

  field :first_name
  field :mi
  field :last_name

  field :email, :accessible => true
  field :security_key

  attr_accessible :first_name
  attr_accessible 'mi', :last_name

  attr :regular_attr_1, :writable => true
  attr :regular_attr_2, :writable => true

  attr_accessible :regular_attr_1

  embeds_many :roles
end

class Role
  include Mongoid::Document
  field :name
  embedded_in :user, :inverse_of => :roles
end

describe Mongoid::Document, ".attr_accessible" do
  context "ordinary fields" do
    it "should be bulk updatable if named" do
      user = User.new(:first_name => 'Foo', :mi => 'B', :last_name => 'Ar')
      user.first_name.should == 'Foo'
      user.mi.should == 'B'
      user.last_name.should == 'Ar'
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

  context "other setters" do
    before do
      @user = User.new
      @user.process(:regular_attr_1 => 'Foo', :regular_attr_2 => 'Bar')
    end

    it "should be bulk-updateable if named" do
      @user.attributes = { :regular_attr_1 => 'Foo' }
      @user.regular_attr_1.should == 'Foo'
    end

    it "should not be bulk updatable otherwise" do
      @user.attributes = { :regular_attr_2 => 'Bar' }
      @user.regular_attr_2.should be_nil
    end
  end

  context "associations" do
    it "should not be bulk updatable" do
      role_json = {
        '_id' => "4bee89c6aea6ec4457000005",
        '_type' => "Role",
        'name' => "Administrator"
      }
      user = User.new(:roles => [role_json])
      user.roles.should == []
    end
  end

  # context "inheritence"
end
