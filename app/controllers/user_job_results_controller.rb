class UserJobResultsController < ApplicationController
  skip_authorization_check

  def index
    @user_job_results = UserJobResult.where(person_id: current_person.id)
    render "index"
  end
end
