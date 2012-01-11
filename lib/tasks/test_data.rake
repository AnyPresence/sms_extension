namespace :db do
  namespace :seed do
    desc "Load the testing seed data from db/test_data.rb"
    task :test do
      require File.join(Rails.root, 'db', 'test_data.rb')
    end
  end
  
  desc "Drops the database, loads application seed and testing seed data"
  task :rebuild_test => ["db:drop", "db:seed", "db:seed:test"]
end
