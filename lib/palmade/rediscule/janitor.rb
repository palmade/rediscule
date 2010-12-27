module Palmade::Rediscule
  class Janitor < Daemon
    include Constants

    def perform_job_one_unit(job)
      job.maintain
    end
  end
end
