class UserJobResultsController < ApplicationController
  skip_authorization_check

  def index
    @user_job_results =
      UserJobResult.includes([:generated_file_attachment]).where(person_id: current_person.id)
    render "index"
  end
end
