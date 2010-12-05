require File.expand_path('../spec_helper', __FILE__)

Palmade::Rediscule::SpecHelper.connect_to_redis

context "BaseQueue" do
  describe "push" do
    before(:all) do
      @queue = Palmade::Rediscule::BaseQueue.new(SPEC_BASE_QUEUE)
      @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

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
      @queue = Palmade::Rediscule::BaseQueue.new(SPEC_BASE_QUEUE)
      @queue.set_rcache(Palmade::Rediscule::SpecHelper.rcache)

      @pushed_ik = @queue.push("test")
      @poped_ik = @queue.pop
    end

    it "should pop the pushed item" do
      @poped_ik.trx_id.should == @pushed_ik.trx_id
    end

    it "should be able to retrieve data" do
      @poped_ik.get.should == "test"
    end

    after(:all) do
      @poped_ik.destroy
      @queue.destroy
    end
  end
end
