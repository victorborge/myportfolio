web: bundle exec "rake db:migrate && puma -C config/puma.rb"
worker: bundle exec sidekiq -q default -q mailers