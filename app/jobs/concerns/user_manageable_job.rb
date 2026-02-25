#  Copyright (c) 2012-2026, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module UserManageableJob
  extend ActiveSupport::Concern

  prepended do
    class_attribute :job_name, default: self.name
    self.parameters = self.parameters.to_a + [:user_job_result_id]
  end

  def enqueue!
    current_person = Auth.current_person
    raise "User manageable jobs must be called from context with auth user" unless current_person

    user_job_result = UserJobResult.create!(
      person_id: current_person.id, name: self.job_name,
      status: "planned", start_timestamp: Time.now.to_i,
      attempts: 0
    )
    @user_job_result_id = user_job_result.id

    delayed_job = super
    user_job_result.update!(delayed_job:)
    delayed_job
  end

  def before(delayed_job)
    user_job_result&.update!(status: "in_progress")
    super
  end

  def success(job = nil)
    user_job_result&.update!(status: "success")
    super if defined?(super)
  end

  def error(_job, exception, payload = parameters)
    if user_job_result.attempts == Delayed::Worker.max_attempts
      user_job_result&.update!(status: "error")
    end
    super
  end

  def user_job_result
    @user_job_result ||= UserJobResult.find(@user_job_result_id)
  end
end
