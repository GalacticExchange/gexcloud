# my vars
# load env

require 'json'

# some settings

# network
NETWORK_NAME = 'net55'
SERVERS = {
    'nfs'=>{
        'net' =>NETWORK_NAME,
        #'ip'=>'10.1.0.121',
        #'run_options'=>'-v /var/run/docker.sock:/var/run/docker.sock'
    },
}


##########

#
common({
     'prefix' => "devgex-",
     'image_prefix' => 'devgex-',
     'dir_data' => '/disk3/data/devgex/',

})

servers({

  'nfs'=>{
      'build' => {
          'build_type' => 'Dockerfile',
          "image_name" => "nfs",

      },
      'docker'=> {
          #"command"=> "",
          'ports' => [
              #[3306,3306],
          ],
          'volumes' => [
              %w(exports /exports)
          ],
          'links' => [],
          'run_env'=>[
          ]
      },
      'attributes' => {
      }
  },

})

base({
})
