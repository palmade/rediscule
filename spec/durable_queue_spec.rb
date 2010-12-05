require File.expand_path('../spec_helper', __FILE__)

context "DurableQueue" do
  describe "push" do
    before(:all) do
      @queue = Palmade::Rediscule::DurableQueue.new(SPEC_DURABLE_QUEUE)
      @rcache = @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

      @ik = @queue.push("test")
    end

    it "should generate a new trx_id" do
      @ik.trx_id.should_not be_nil
      @ik.trx_id.should_not be_empty
    end

    it "should set the test data" do
      @ik.exists?.should be_true
      @ik.get.should == "test"
    end

    it "should push to the queue" do
      @queue.rcache.lindex(@queue.queue_cache_key, 0).should == @ik.trx_id
    end

    after(:all) do
      @ik.destroy
      @queue.destroy
    end
  end

  describe "pop" do
    before(:all) do
      @queue = Palmade::Rediscule::DurableQueue.new(SPEC_DURABLE_QUEUE)
      @rcache = @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

      @pushed_ik = @queue.push("test")
      @poped_ik = @queue.pop
    end

    it "should pop the same pushed item" do
      @poped_ik.trx_id.should == @pushed_ik.trx_id
    end

    it "should enqueue to the working queue" do
      @rcache.llen(@queue.working_cache_key).should == 1
      @rcache.lindex(@queue.working_cache_key, 0).should == @poped_ik.trx_id
    end

    it "should timestamp item worked_at" do
      @poped_ik.worked_at.should be_an_instance_of Time
      @poped_ik.worked_at.should > (Time.now.utc - 1)
    end

    after(:all) do
      @poped_ik.destroy
      @queue.destroy
    end
  end

  describe "pop and done" do
    before(:all) do
      @queue = Palmade::Rediscule::DurableQueue.new(SPEC_DURABLE_QUEUE)
      @rcache = @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

      @pushed_ik = @queue.push("test")
      @poped_ik = @queue.pop
      @poped_ik.done!
    end

    it "should remove the item from the working queue" do
      @rcache.llen(@queue.working_cache_key).should == 0
    end

    it "should remove the item from the retries queue" do
      @rcache.llen(@queue.retries_cache_key).should == 0
    end

    after(:all) do
      @poped_ik.destroy
      @queue.destroy
    end
  end

  describe "pop and retry later" do
    before(:all) do
      @queue = Palmade::Rediscule::DurableQueue.new(SPEC_DURABLE_QUEUE)
      @rcache = @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

      @pushed_ik = @queue.push("test")
      @poped_ik = @queue.pop
      @poped_ik.retry_later
    end

    it "should remove the item from the working queue" do
      @rcache.llen(@queue.working_cache_key).should == 0
    end

    it "should add the 1 item to the retries queue" do
      @rcache.llen(@queue.retries_cache_key).should == 1
    end

    it "should add the same item" do
      @rcache.lindex(@queue.retries_cache_key, 0).should == @poped_ik.trx_id
    end

    it "should increment rt count" do
      @poped_ik.rt_count.should == 1
    end

    it "should set the rt at based on the interval" do
      @poped_ik.rt_at.should > (Time.now.utc + (@queue.rt_at_interval * @poped_ik.rt_count) - 1)
    end

    after(:all) do
      @poped_ik.destroy
      @queue.destroy
    end
  end
end
