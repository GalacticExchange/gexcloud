set :gex_env, 'main'

server_ip = '51.1.1.21'

#
role :app, [server_ip]
role :web, [server_ip]
role :db,  [server_ip]



#
set :application, 'apihub'
set :rails_env, 'main'
set :branch, "master"

server server_ip, user: 'uadmin', roles: %w{web}, primary: true
set :deploy_to, "/var/www/apps/#{fetch(:application)}"

set :ssh_options, { forward_agent: true, paranoid: false,  user: 'uadmin', password: 'PH_GEX_PASSWD1'}



set :repo_url, 'git@git.gex:gex/apihub.git'
