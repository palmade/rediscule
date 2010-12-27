require File.expand_path('../spec_helper', __FILE__)

context "Jobber" do
  describe "daemon" do
    before(:all) do
      Palmade::Rediscule.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/jobber.yml"
        map_job "test", :class_name => "TestWorker"
      end

      @jobber = Palmade::Rediscule.jobber
      @daemon = Palmade::Rediscule::Daemon.start(@jobber, "test")
    end

    it "should instantiate a daemon" do
      @daemon.should_not be_nil
      @daemon.should be_an_instance_of(Palmade::Rediscule::Daemon)
    end

    it "should set params properly" do
      @daemon.jobber.should == @jobber
      @daemon.job_keys.should_not be_empty
      @daemon.job_keys.size.should == 1
      @daemon.job_keys.first.should == "test"
    end

    it "should call with no job" do
      @daemon.call
    end

    after(:all) do
      Palmade::Rediscule.jobber = nil
    end
  end
end
