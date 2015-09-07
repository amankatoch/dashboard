# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'practicegigs'
set :repo_url, 'git@github.com:PracticeGigs/backend.git'

set :puma_threads,    [4, 16]
set :puma_workers,    0

set :resque_environment_task, true
set :workers, {
  app: { "apn" => 1, "mailer" => 1 }
}
after "deploy:restart", "resque:restart"

set :rvm_type, :user                     # Defaults to: :auto
#set :rvm_ruby_version, '2.1.3'      # Defaults to: 'default'
#set :rvm_custom_path, '~/.myveryownrvm'  # only needed if not detected

set :nginx_sudo_paths, [:nginx_sites_enabled_dir, :nginx_sites_available_dir]

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml config/secrets.yml config/apn.pem config/application.yml
                      config/cloudinary.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  # desc 'Restart application'
  # task :restart do
  #   on roles(:app), in: :sequence, wait: 5 do
  #     # Your restart mechanism here, for example:
  #     execute :touch, release_path.join('tmp/restart.txt')
  #   end
  # end

  # after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end

after 'deploy:publishing', 'resque:restart'
after 'puma:restart', 'nginx:restart'

namespace :rails do
  desc "Open the rails console on the remote server"
  task :console do
    on roles(:app), primary: true do |host|
      rails_env = fetch(:stage)
      execute_interactively_rails "console #{rails_env}", host
    end
  end

  desc "Open the rails db console on the remote server"
  task :db do
    on roles(:app), primary: true do |host|
      rails_env = fetch(:stage)
      execute_interactively_rails "db -p #{rails_env}", host
      end
  end

  desc "Open the rails db console on the remote server"
  task :log do
    on roles(:app), primary: true do |host|
      rails_env = fetch(:stage)
      execute_interactively "tail -f log/#{rails_env}.log", host
      end
  end

  def execute_interactively(command, host)
    user = host.user
    port = host.port || 22
    exec "ssh -l #{user} #{host.hostname} -p #{port} -t \"~/.rvm/bin/rvm-shell -c 'cd #{deploy_to}/current && #{command}'\""
  end

  def execute_interactively_rails(command, host)
    execute_interactively "bundle exec rails #{command}", host
  end
end
