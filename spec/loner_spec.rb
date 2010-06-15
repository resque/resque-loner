require File.dirname(__FILE__) + '/spec_helper'

class SomeJob
  @queue = :some_queue
end

class SomeLonerJob < Resque::Plugins::Loner::LonerJob
  @queue = :other_queue
  def self.perform
  end
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
  
  it "should allow the same jobs to be executed one after the other" do
    Resque.enqueue SomeLonerJob, "foo"
    Resque.enqueue SomeLonerJob, "foo"
    Resque.size(:other_queue).should == 1

    Resque.reserve(:other_queue)
    Resque.size(:other_queue).should == 0

    Resque.enqueue SomeLonerJob, "foo"
    Resque.enqueue SomeLonerJob, "foo"
    Resque.size(:other_queue).should == 1
  end
  
  it "should be robust regarding hash attributes" do
    Resque.enqueue SomeLonerJob, :bar => 1, :foo => 2
    Resque.enqueue SomeLonerJob, :foo => 2, :bar => 1
    Resque.size(:other_queue).should == 1
  end
  
  it "should be robust regarding hash attributes (JSON does not distinguish between string and symbol)" do
    Resque.enqueue SomeLonerJob, :bar => 1, :foo  => 1
    Resque.enqueue SomeLonerJob, :bar => 1, "foo" => 1
    Resque.size(:other_queue).should == 1
  end
  
  it "should mark jobs as unqueued, when Job.destroy is killing them" do
    Resque.enqueue SomeLonerJob, "foo"
    Resque.enqueue SomeLonerJob, "foo"
    Resque.size(:other_queue).should == 1

    Resque::Job.destroy(:other_queue, SomeLonerJob)
    Resque.size(:other_queue).should == 0

    Resque.enqueue SomeLonerJob, "foo"
    Resque.enqueue SomeLonerJob, "foo"
    Resque.size(:other_queue).should == 1
  end
  
end
