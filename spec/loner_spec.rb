require File.dirname(__FILE__) + '/spec_helper'

class SomeJob
  @queue = :some_queue
end

class SomeLonerJob < Resque::LonerJob
  @queue = :other_queue
end

describe "Resque" do

  before(:each) do
    Resque.redis.flushall
  end
  
  it "can put multiple normal jobs on a queue" do
    Resque.enqueue SomeJob, "foo"
    Resque.enqueue SomeJob, "foo"
    Resque.size(:some_queue).should == 2
  end
  
  it "only one of the same job sits in a queue" do
    Resque.enqueue SomeLonerJob, "foo"
    Resque.enqueue SomeLonerJob, "foo"
    Resque.size(:other_queue).should == 1
  end
  
end
