require 'spec_helper'

#
#  Resque-loner specific specs. I'm shooting right through the stack here and just
#  test the outcomes, because the implementation will change soon and the tests run
#  quite quickly.
#

class SomeJob
  @queue = :some_queue
end

class SomeUniqueJob
  include Resque::Plugins::UniqueJob
  @queue = :other_queue
  def self.perform(foo); end
end

class FailingUniqueJob
  include Resque::Plugins::UniqueJob
  @queue = :other_queue
  def self.perform(foo)
    fail 'I beg to differ'
  end
end

class DeprecatedUniqueJob < Resque::Plugins::Loner::UniqueJob
  @queue = :other_queue
  def self.perform(foo); end
end

class UniqueJobWithTtl
  include Resque::Plugins::UniqueJob
  @queue = :unique_with_ttl
  @loner_ttl = 300
  def self.perform(*args); end
end

class UniqueJobWithLockAfterExecution
  include Resque::Plugins::UniqueJob
  @queue = :unique_with_loner_lock_after_execution_period
  @loner_lock_after_execution_period = 150
  def self.perform(*args); end
end

describe 'Resque' do

  before(:each) do
    Resque.data_store.redis.flushall
    Resque.size(:other_queue).should == 0
    Resque.size(:some_queue).should == 0
  end

  describe 'Jobs' do
    it 'can put multiple normal jobs on a queue' do
      Resque.enqueue SomeJob, 'foo'
      Resque.enqueue SomeJob, 'foo'
      Resque.size(:some_queue).should == 2
    end

    it 'should allow only one of the same job to sit in a queue' do
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1
    end

    it 'should support deprecated Resque::Plugins::Loner::UniqueJob class' do
      Resque.enqueue DeprecatedUniqueJob, 'foo'
      Resque.enqueue DeprecatedUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1
    end

    it 'should allow the same jobs to be executed one after the other' do
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1

      Resque.reserve(:other_queue)
      Resque.size(:other_queue).should == 0

      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1
    end

    it 'should be robust regarding hash attributes' do
      Resque.enqueue SomeUniqueJob, bar: 1, foo: 2
      Resque.enqueue SomeUniqueJob, foo: 2, bar: 1
      Resque.size(:other_queue).should == 1
    end

    it 'should be robust regarding hash attributes (JSON does not distinguish between string and symbol)' do
      Resque.enqueue SomeUniqueJob, bar: 1, foo: 1
      Resque.enqueue SomeUniqueJob, :bar => 1, 'foo' => 1
      Resque.size(:other_queue).should == 1
    end

    it 'should mark jobs as unqueued, when Job.destroy is killing them' do
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1

      Resque::Job.destroy(:other_queue, SomeUniqueJob)
      Resque.size(:other_queue).should == 0

      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.size(:other_queue).should == 1
    end

    it 'should mark jobs as unqueued, when they raise an exception during #perform' do
      2.times { Resque.enqueue(FailingUniqueJob, 'foo') }
      Resque.size(:other_queue).should == 1

      worker = Resque::Worker.new(:other_queue)
      worker.work 0
      Resque.size(:other_queue).should == 0

      2.times { Resque.enqueue(FailingUniqueJob, 'foo') }
      Resque.size(:other_queue).should == 1
    end

    it 'should report if a job is queued or not' do
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueued?(SomeUniqueJob, 'foo').should be true
      Resque.enqueued?(SomeUniqueJob, 'bar').should be false
    end

    it 'should report if a job is in a special queue or not' do
      default_queue = SomeUniqueJob.instance_variable_get(:@queue)
      SomeUniqueJob.instance_variable_set(:@queue, :special_queue)

      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueued_in?(:special_queue, SomeUniqueJob, 'foo').should be true

      SomeUniqueJob.instance_variable_set(:@queue, default_queue)

      Resque.enqueued?(SomeUniqueJob, 'foo').should be false
    end

    it 'should not be able to report if a non-unique job was enqueued' do
      Resque.enqueued?(SomeJob).should be_nil
    end

    it 'should cleanup all loners when a queue is destroyed' do
      Resque.enqueue SomeUniqueJob, 'foo'
      Resque.enqueue FailingUniqueJob, 'foo'

      Resque.remove_queue(:other_queue)

      Resque.enqueue(SomeUniqueJob, 'foo')
      Resque.size(:other_queue).should == 1
    end

    it 'should not raise an error when deleting an already empty queue' do
      expect { Resque.remove_queue(:other_queue) }.to_not raise_error
    end

    it 'should honor loner_ttl in the redis key' do
      Resque.enqueue UniqueJobWithTtl
      Resque.enqueued?(UniqueJobWithTtl).should be true
      k = Resque.redis.keys 'loners:queue:unique_with_ttl:job:*'
      k.length.should == 1
      Resque.redis.ttl(k[0]).should be_within(2).of(UniqueJobWithTtl.loner_ttl)
    end

    it 'should not allow the same job to be enqueued after execution if loner_lock_after_execution_period is set' do
      Resque.enqueue UniqueJobWithLockAfterExecution, 'foo'
      Resque.enqueue UniqueJobWithLockAfterExecution, 'foo'
      Resque.size(:unique_with_loner_lock_after_execution_period).should == 1

      Resque.reserve(:unique_with_loner_lock_after_execution_period)
      Resque.size(:unique_with_loner_lock_after_execution_period).should == 0

      Resque.enqueue UniqueJobWithLockAfterExecution, 'foo'
      Resque.size(:unique_with_loner_lock_after_execution_period).should == 0
    end

    it 'should honor loner_lock_after_execution_period in the redis key' do
      Resque.enqueue UniqueJobWithLockAfterExecution
      Resque.reserve(:unique_with_loner_lock_after_execution_period)
      k = Resque.redis.keys 'loners:queue:unique_with_loner_lock_after_execution_period:job:*'
      k.length.should == 1
      Resque.redis.ttl(k[0]).should be_within(2).of(UniqueJobWithLockAfterExecution.loner_lock_after_execution_period)
    end
  end
end
