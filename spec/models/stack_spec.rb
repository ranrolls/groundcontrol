require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "An Empty Stack" do
  before(:each) do
    @stack = Stack.new
  end

  it "should not be valid while empty" do
    @stack.should_not be_valid
  end
  
  it "should not be savable" do
    @stack.save.should == false
  end
  
  it "should have the expected associations" do
    @stack.roles.should be_empty
  end
end

describe "A newly created Stack" do
  before(:each) do
    @stack = Stack.new
  end
  
  it "should be able to be populated with data and saved" do
    new_name = "Stack rspec test"
    @stack.name   = new_name
    @stack.roles << roles(:webapp)
    @stack.roles << roles(:reactor)
    
    @stack.should be_valid
    @stack.save.should == true
    @stack.roles.should_not be_empty
    @stack.roles.size.should == 2
  end
end
