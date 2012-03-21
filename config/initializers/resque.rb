Resque.redis = REDIS

Resque.after_fork = Proc.new do
  Rails.logger.auto_flushing = true if Rails.logger.respond_to?(:auto_flushing)
end
