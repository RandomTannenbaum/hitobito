class MigrateAsyncDownloadFileToUserJobResult < ActiveRecord::Migration[8.0]
  def change
    rename_table :async_download_files, :user_job_results
    change_table :user_job_results do |t|
      t.rename :timestamp, :start_timestamp
      t.string :end_timestamp
      t.string :status
      t.integer :attempts
      t.references :delayed_job, foreign_key: false
    end
  end
end
