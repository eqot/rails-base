# config valid only for Capistrano 3.1
lock '3.1.0'

set :application, 'my_app'
set :repo_url, 'git@example.com:me/my_app.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/usr/share/nginx/rails/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do
  after :publishing, :restart

  set :unicorn_pid, "/var/tmp/unicorn.pid"
  set :unicorn_config, "#{current_path}/config/unicorn.conf.rb"

  def start_unicorn
    within current_path do
      execute :bundle, :exec, :unicorn, "-c #{fetch(:unicorn_config)} -E #{fetch(:rails_env)} -D"
    end
  end

  def stop_unicorn
    execute :kill, "-QUIT `cat #{fetch(:unicorn_pid)}`"
  end

  def reload_unicorn
    execute :kill, "-USR2 `cat #{fetch(:unicorn_pid)}`"
    execute :kill, "-QUIT `cat #{fetch(:unicorn_pid)}.oldbin`"
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      if test("[ -f #{fetch(:unicorn_pid)} ]")
        reload_unicorn
      else
        start_unicorn
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

  after :finished, :notify do
    system("which -s growlnotify && growlnotify -n 'Capistrano' -t 'Capistrano' -m 'Completed.'")
  end
end
