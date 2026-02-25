#  Copyright (c) 2012-2026, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe UserManageableJob do
  let(:person) { people(:top_leader) }

  before do
    allow(Auth).to receive(:current_person).and_return(person)
  end

  it "should have reference to user job result when job is enqueued" do
    job = Examples::SuccessfulUserManagedJob.new
    job.enqueue!

    expect(job.user_job_result).not_to be_nil
  end

  it "should have status planned when in queue initially" do
    job = Examples::SuccessfulUserManagedJob.new
    job.enqueue!

    user_job_result = job.user_job_result
    expect(user_job_result.status).to eql("planned")
  end

  it "should have status in_progress when job is being worked off" do
    job = Examples::LongRunningUserManagedJob.new
    job.enqueue!
    job_worker_thread = Thread.new do
      work_off_jobs
    end

    sleep 3
    user_job_result = job.user_job_result
    expect(user_job_result.status).to eql("in_progress")
    job_worker_thread.terminate
  end

  it "should have status success when job has been worked off without any errors" do
    job = Examples::SuccessfulUserManagedJob.new.enqueue!

    expect { work_off_jobs }.to change(Delayed::Job, :count).by(-1)

    user_job_result = job.user_job_result
    expect(user_job_result.status).to eql("success")
  end

  it "should have status error when last job retry failed" do
    job = Examples::UnsuccessfulUserManagedJob.new
    job.enqueue!
    work_off_jobs

    user_job_result = job.user_job_result
    expect(user_job_result.status).to eql("error")
    expect(user_job_result.attempts).to eql(2)
  end

  def work_off_jobs
    worker = Delayed::Worker.new
    worker.max_run_time = 10.seconds
    worker.max_attempts = 2
    worker.work_off
  end
end
