Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
  
  config.on(:startup) do
    schedule_file = Rails.root.join('config', 'schedule.yml')
    Sidekiq::Scheduler.reload_schedule! if File.exist?(schedule_file)
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
