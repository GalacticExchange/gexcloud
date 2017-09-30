module Helper

  UBUNTU_AMI = {
      '16.04' => 'ami-7c803d1c',
      '15.10' => 'ami-58445f39'
  }

  DEFAULT_REGION = 'us-west-2'

  #IMPORTANT: all regions except default!!!
  # noinspection RubyLiteralArrayInspection
  AWS_REGIONS = [
      'us-east-1',
      'us-east-2',
      'us-west-1',
      'ap-northeast-2',
      'ap-southeast-1',
      'ap-southeast-2',
      'ap-northeast-1',
      'eu-central-1',
      'eu-west-1',
      'eu-west-2',
      'ca-central-1',
      'ap-south-1',
      'sa-east-1'
  ]

  BUCKET_URL = 'https://s3-us-west-1.amazonaws.com/gex-ami-ids/'
  AMI_S3_SUFFIX = '_id.txt'

  GEXD_DEB = {
      :main => {
          :repo => 'khotkevych',
          :package => 'gexservertest'
      },
      :prod => {
          :repo => 'gex',
          :package => 'gexserver'
      }
  }

end