require "resque/tasks"


task "resque:setup" => :environment do
  ENV['QUEUE'] = '*'
  Rails.logger.flush
  Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
end
