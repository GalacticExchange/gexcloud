#!/usr/bin/env ruby
require 'fog'


=begin
connection = Fog::Storage.new({
  :provider                 => 'AWS',
  :aws_access_key_id        => 'PH_GEX_KEY_ID',
  :region                   => 'us-west-1',
  :aws_secret_access_key    => 'PH_GEX_ACESS_KEY'
})

bucket = connection.directories.get('gex-containers')

puts bucket.files.methods.sort

#create(:key=>'name_on_bucket',:body=>File.open('local_name.rb'),:public=>true)
bucket.files.create(:key=>'install_scripts',:body=>File.open('install_scripts.rb'),:public=>true)



bucket.files.get('install_scripts').destroy

=end

fog = Fog::Compute.new(
    :provider => 'AWS',
    :region => 'us-west-2',
    :aws_access_key_id => 'PH_GEX_KEY_ID',
    :aws_secret_access_key => 'PH_GEX_ACESS_KEY'
)




#TODO request image info by its id
image_info = fog.describe_images('ImageId' => 'ami-19985779').body['imagesSet']

puts image_info[0]['imageState']

#Waiting for ami totally come up
while image_info[0]['imageState'] != 'available' do
  print '.'
  sleep(2.minutes)
  image_info = fog.describe_images('ImageId' => 'ami-19985779').body['imagesSet']
end

#TODO destroy instance



