require_relative 'aws_sync'

def sync_box(file_path)
  Aws.config.update({
                        :access_key_id => ACCESS_KEY_ID,
                        :secret_access_key => SECRET_ACCESS_KEY
                    })

  s3 = Aws::S3::Resource.new(region: 'us-west-1')
  new_filename = File.basename(file_path)

  version_file = parse_box_version_file(new_filename)
  old_filename = get_box_name(version_file)

  #creating copy of last version, renaming it as new version
  s3.bucket('gex-boxes').object("#{new_filename}").copy_from("gex-boxes/#{old_filename}", acl: 'public-read')

  aws_sync('gex-boxes', new_filename, file_path)
end


def parse_box_version_file(file_name)
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
  suffix + '-version.txt'
end

def get_box_name(version_file)
  version = get_version('gex-boxes', version_file)
  box_name = ''
  case version_file
    when /cdh/
      box_name = 'gex-'+version+'-cdh.box'
    when /plain/
      box_name = 'gex-'+version+'-plain.box'
    else
      # type code here
  end
  box_name
end
