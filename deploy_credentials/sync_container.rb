require_relative 'aws_sync'

def sync_container(file_path)
  Aws.config.update({
                        :access_key_id => ACCESS_KEY_ID,
                        :secret_access_key => SECRET_ACCESS_KEY
                    })

  s3 = Aws::S3::Resource.new(region: 'us-west-1')
  new_filename = File.basename(file_path)

  version_file = parse_container_version_file(new_filename)
  old_filename = get_container_name(version_file)

  #creating copy of last version, renaming it as new version
  s3.bucket('gex-containers').object("#{new_filename}").copy_from("gex-containers/#{old_filename}", acl: 'public-read')

  aws_sync('gex-containers', new_filename, file_path)
end

def parse_container_version_file(file_name)
  case file_name
    when /hue_cdh/
      suffix = 'hue_cdh'
    when /hue_plain/
      suffix = 'hue_plain'
    when /hadoop_cdh_client/
      suffix = 'hadoop_cdh_client'
    when /hadoop_plain_client/
      suffix = 'hadoop_plain_client'
    when /hadoop_cdh_master/
      suffix = 'hadoop_cdh_master'
    when /hadoop_plain_master/
      suffix = 'hadoop_plain_master'
    else
      raise 'Cannot parse file name'
  end
  suffix + '-version.txt'
end

def get_container_name(version_file)
  version = get_version('gex-containers', version_file)
  container_name = ''
  case version_file
    when /hue_cdh/
      container_name = 'gex-hue_cdh-'+version+'.tar'
    when /hue_plain/
      container_name = 'gex-hue_plain-'+version+'.tar'
    when /hadoop_cdh_client/
      container_name = 'gex-hadoop_cdh_client-'+version+'.tar'
    when /hadoop_plain_client/
      container_name = 'gex-hadoop_plain_client-'+version+'.tar'
    when /hadoop_cdh_master/
      container_name = 'gex-hadoop_cdh_master-'+version+'.tar'
    when /hadoop_plain_master/
      container_name = 'gex-hadoop_plain_master-'+version+'.tar'
    else
      # type code here
  end
  container_name
end
