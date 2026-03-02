module DelayedJobSpecHelper
  def work_off_job(job)
    worker = Delayed::Worker.new
    worker.max_run_time = 10.seconds
    worker.max_attempts = 2
    worker.run(job)
  end
end
