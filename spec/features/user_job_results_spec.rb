#  Copyright (c) 2012-2026, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe :person_duplicates, js: true do
  include DelayedJobSpecHelper

  let(:top_leader) { people(:top_leader) }

  before do
    allow(Auth).to receive(:current_person).and_return(top_leader)
    sign_in(top_leader)
  end

  it "should show info about successful job without progress" do
    job = Examples::SuccessfulUserManagedJob.new
    work_off_job(job.enqueue!)
    visit user_job_results_path

    expect(page).to have_css(".fas .fa-circle-check")
    expect(page).to have_content("Custom Job Name")
    expect(page).to have_content("Versuche: 1/2")
    check_common_content_for_basic_jobs
  end

  it "should show info about unsuccessful job without progress" do
    job = Examples::UnsuccessfulUserManagedJob.new
    work_off_job(job.enqueue!)
    visit user_job_results_path

    expect(page).to have_css(".fas .fa-circle-xmark")
    expect(page).to have_content("Examples::UnsuccessfulUserManagedJob")
    expect(page).to have_content("Versuche: 2/2")
    check_common_content_for_basic_jobs
  end

  it "should show info about successful job with progress" do
    job = Examples::UserManagedJobWithProgress.new
    work_off_job(job.enqueue!)
    visit user_job_results_path

    expect(page).to have_css(".fas .fa-circle-check")
    expect(page).to have_content("Examples::UserManagedJobWithProgress")
    expect(page).to have_content("Versuche: 1/2")
    expect(page).to have_css(".progress")
    expect(page).to have_css("div[class='progress-bar', style='width: 100%']")
    expect(page).to have_content("Startzeitpunkt")
    expect(page).to have_content("Endzeitpunkt")
    expect(page).not_to have_content(".fas .fa-download")
  end


  it "should show info about successful download job" do
    job = Examples::UserManagedJobWithProgress.new
    work_off_job(job.enqueue!)
    visit user_job_results_path

    expect(page).to have_css(".fas .fa-circle-check")
    expect(page).to have_content("Examples::UserManagedJobWithProgress")
    expect(page).to have_content("Versuche: 1/2")
    expect(page).to have_content("Dieser Job hat keinen nachverfolgbaren Fortschritt")
    expect(page).not_to have_css(".progress")
    expect(page).to have_content("Startzeitpunkt")
    expect(page).to have_content("Endzeitpunkt")
    expect(page).to have_content(".fas .fa-download")
  end

  def check_common_content_for_basic_jobs
    expect(page).to have_content("Dieser Job hat keinen nachverfolgbaren Fortschritt")
    expect(page).not_to have_css(".progress")
    expect(page).to have_content("Startzeitpunkt")
    expect(page).to have_content("Endzeitpunkt")
    expect(page).not_to have_content(".fas .fa-download")
  end
end
