namespace :gex_deploy do

  desc 'copy configs'
  task :copy_configs do
    on roles(:app) do
      #execute "cd #{current_path} && bundle install --no-deployment "
      files = {
          "config/gex/gex_config.#{fetch(:gex_env)}.yml" => "config/gex/gex_config.yml"
      }
      files.each do |f, f_out|
        upload! f, "#{current_path}/#{f_out}"
      end
    end
  end

  desc 'update ansible scripts'
  task :update_ansible do
    on roles(:app) do
      execute "cd /var/www/ansible && git pull origin master --depth 1"
    end
  end

  desc 'update chef'
  task :update_chef do
    on roles(:app) do
      execute "cd /var/www/chef && git pull origin master --depth 1"
    end
  end


  desc 'clean cache options'
  task :clear_cache_options do
    #run_locally("RAILS_ENV=#{fetch(:rails_env)} rake cache:options:clear")

    on roles(:app) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          begin
            execute :rake, "cache:options_clear"
          end
        end
      end
    end
  end


end

