#TODO parse and merge base attrs frome node.json ???

# 0 download container
ruby_block 'download container' do
  block do
    version_txt = URI.join(node['common']['files_url'], node['app_name'])
    "wget #{version_txt}"
    #todo ...
  end
end

# 1 install container
# sudo /home/vagrant/ruby_scripts/install_container.rb applications/data_enchilada/gex-data_enchilada-0.0.86.08_10_2017_1502378116.tar.gz data_enchilada

docker_image node['app']['image_name'] do
  action :remove
end

docker_container node['app']['name'] do
  action :remove
end

docker_image node['app']['image_name'] do
  source File.join('/tmp', node['app']['name']) # path to tar file
  action :import
end


include_recipe 'gex::container_install'




# run container
#sudo /home/vagrant/ruby_scripts/run_container.rb data_enchilada applications/data_enchilada/config.json