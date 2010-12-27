require File.expand_path('../spec_helper', __FILE__)

context "Jobber" do
  describe "configure" do
    before(:all) do
      Palmade::Rediscule.configure do
        init SPEC_ROOT, SPEC_ENV
        config "spec/config/jobber.yml"
        map_job "test", :class_name => "TestWorker"
      end

      @jobber = Palmade::Rediscule.jobber
      @job = @jobber.jobs["test"]
      @job.set_rcache(Palmade::Rediscule::SpecHelper.rcache)
    end

    it "should initialize a jobber instance" do
      @jobber.should_not be_nil
    end

    it "should contain one job spec" do
      @jobber.jobs.should_not be_empty
      @jobber.jobs.size.should == 1
      @jobber.jobs.keys.first.should == "test"
    end

    it "should instantiate the correct Job instance" do
      @job.should be_an_instance_of(Palmade::Rediscule::Job)
      @job.job_key.should == "test"
    end

    after(:all) do
      @job.destroy
      Palmade::Rediscule.jobber = nil
    end
  end
end
