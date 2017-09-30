set :gex_env, 'production'

#server_ip = '104.247.194.115'
server_ip = '51.0.1.21'

#
role :app, [server_ip]
role :web, [server_ip]
role :db,  [server_ip]



#
set :application, 'apihub'
set :rails_env, 'production'
#set :repo_url, 'ssh://git@46.172.71.50:5522/gex/apihub.git'
set :repo_url, 'ssh://git@git.galacticexchange.io:5522/gex/apihub.git'
#set :branch, "v_0_2_1"
set :branch, "master"

server "#{server_ip}:22", user: 'uadmin', roles: %w{web}, primary: true
set :deploy_to, "/var/www/apps/#{fetch(:application)}"

#set :ssh_options, { forward_agent: true, user: 'uadmin', }
set :ssh_options, { forward_agent: true, paranoid: false,  user: 'uadmin', password: 'PH_GEX_PASSWD1'}

