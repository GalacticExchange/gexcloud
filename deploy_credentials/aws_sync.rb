require 'net/http'
require 'aws-sdk'
require_relative 'credentials'

MOUNT_PATH = '/mnt/aws_sync'
AWS_CREDENTIALS_PATH = File.join(File.dirname(__FILE__), 'aws_credentials')

#ACCESS_KEY_ID = 'PH_GEX_KEY_ID'
#SECRET_ACCESS_KEY = 'PH_GEX_ACESS_KEY'




def parse_version_file(file_name)

  version_file = nil
  suffix = nil

  # /some_string/ checks that variable contains string

  if file_name.include? '.tar' #assuming that its gex-containers bucket

    case file_name
      when /hue_cdh/
        suffix = 'hue_cdh'
      when /hue_plain/
        suffix = 'hue_plain'
      when /hadoop_cdh_client/
        suffix = 'hadoop_cdh_client'
      when /hadoop_plain_client/
        suffix = 'hadoop_plain_client'
      else
        raise 'Cannot parse file name'
    end

    version_file = suffix + '-version.txt'
    suffix = suffix + '.tar'

  elsif file_name.include? '.box' #assuming that its gex-boxes bucket
    case file_name
      when /cdh/
        suffix = 'cdh'
      when /plain/
        suffix = 'plain'
      when /master/
        suffix = 'master'
      else
        raise 'Cannot parse file name'
    end

    version_file = suffix + '-version.txt'
    suffix = suffix + '.box'
  end
  return version_file, suffix
end

def get_version(bucket_name, version_file)
  str = Net::HTTP.get_response(URI.parse("https://s3-us-west-1.amazonaws.com/#{bucket_name}/#{version_file}")).body

  #splitting by new line
  str = str.split(/\r?\n/)

  #removing substring and returning version
  str[0].gsub('version=', '')
end

def get_filename(version, suffix)
  "gex-#{version}-#{suffix}"
end

# source_file => should be absolute path to file
#
def aws_sync(bucket_name, dest_file, source_file)
  `sudo chmod 600 #{AWS_CREDENTIALS_PATH}`
  bucket_local_folder = File.join(MOUNT_PATH, bucket_name)
  `sudo mkdir -p #{MOUNT_PATH}`

  `sudo rm -rf #{bucket_local_folder}`
  `sudo mkdir #{bucket_local_folder}`

  #mount
  system("sudo s3fs #{bucket_name} #{bucket_local_folder} -o passwd_file=#{AWS_CREDENTIALS_PATH} -o default_acl=public-read")


  system("sudo rsync -avz -L #{source_file} #{File.join(bucket_local_folder, dest_file)}")
  system("sudo umount #{bucket_local_folder}")

end

#sync('gex-ami-ids','node_ami_plain_id_copy.txt','/home/bogdan/test/node_ami_plain_id_copy.txt')