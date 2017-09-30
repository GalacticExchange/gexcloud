GLOBAL_SETTINGS = {
    main: {

        _production: "false",
        _dns_ip: "51.0.1.8",

        _site_login_url: "http://api.devgex.net:8080/signin",
        _api_ip: "51.0.0.21",
        _api_public_ip: "46.172.71.53",
        _box_download: "http://51.0.1.101/boxes/",
        _sensu_rabbitmq_host: "stats.devgex.net",

        _sensu_rabbitmq_user: "sensu",
        _sensu_rabbitmq_password: "PH_GEX_PASSWD1",


        _openvpn_ip_address: "46.172.71.56",
        _openvpn_private_ip_address: "51.0.1.8",
        _socks_proxy_ip: "46.172.71.55",
        _proxy_public_ip: "46.172.71.55",
        _proxy_private_ip: "51.0.1.15",
        _private_bridge: "eth0",
        _webproxy_host: "webproxy.devgex.net",


        #:_redis_host =>"51.0.1.21",
        #:_redis_prefix =>"gex"
        _webproxy_redis_ip: "51.0.0.12",
        _webproxy_redis_prefix: "gex"
    },

    prod: {
        _dns_ip: "51.0.1.8",
        _site_login_url: "http://api.galacticexchange.io/signin",
        _api_ip: "104.247.194.115",
        _api_public_ip: "104.247.194.115",
        _dns_public_ip: "104.247.220.90",
        #_box_download=>"https://gex-boxes.s3-us-west-1.amazonaws.com/",
        _box_download: "http://dxiolmvesnizm.cloudfront.net/",
        _production: "true",
        _sensu_rabbitmq_host: "stats.galacticexchange.io",
        _sensu_rabbitmq_user: "sensu",
        _sensu_rabbitmq_password: "PH_GEX_PASSWD1",
        _openvpn_ip_address: "172.82.184.107",
        _openvpn_private_ip_address: "51.0.1.8",
        _master_private_ip_address: "51.0.1.31",
        _openvpn_ip6_address: "FD9E:9E:9E:0:0:1:8:0/64",
        _socks_proxy_ip: "172.82.184.108",
        _proxy_public_ip: "172.82.184.108",
        _proxy_private_ip: "51.0.1.15",
        _private_bridge: "overlay",
        _webproxy_host: "webproxy.galacticexchange.io",
        #:_redis_host =>"104.247.194.114",
        #:_redis_prefix =>"gex"
        _webproxy_redis_ip: "51.0.0.12",
        _webproxy_redis_prefix: "gex"
    }

}


MASTER_SETTINGS = {
    :global_settings => {
#        :BOX_IMAGE =>"gex/base_master",
:BOX_NAME =>"master",
:DNS_SERVER =>"51.0.1.8"

    },

    :main =>
        {
            :NAME =>"main",
            :PRIVATE_IP =>"51.1.0.50",
            :PRIVATE_MASK =>"255.128.0.0",
            :PRIVATE_IP6 =>"FD9E:9 E:9 E:0:0:1:1 F:0/48",
            :OPENVPN_PRIVATE_IP =>"51.0.1.8",
            :OPENVPN_IP6 =>"fd9e:9 e:9 e::1:8:0/64",
            :MACHINE_NAME =>"master",
            :SENSU_NODE_ID =>"server_master",
            :SENSU_NAME =>"server_master",
            :SENSU_RMQUSER =>"sensu",
            :SENSU_RMQPWD =>"PH_GEX_PASSWD1",
            :SENSU_RMQHOST =>"51.0.1.5",
            :NAME_SERVER =>"51.0.12.21",

            :RAM_SIZE =>"9012"
        },

    :prod =>


        {
            :NAME =>"prod",
            :PRIVATE_IP =>"51.0.1.50",
            :PUBLIC_IP =>"172.82.184.107",
            :PRIVATE_IP6 =>"FD9E:9 E:9 E:0:0:1:1 F:0/48",
            :OPENVPN_PRIVATE_IP =>"51.0.1.8",
            :OPENVPN_IP6 =>"fd9e:9 e:9 e::1:8:0/64",
            :MACHINE_NAME =>"master",
            :SENSU_NODE_ID =>"server_master",
            :SENSU_NAME =>"server_master",
            :SENSU_RMQUSER =>"sensu",
            :SENSU_RMQPWD =>"PH_GEX_PASSWD1",
            :SENSU_RMQHOST =>"51.0.1.5",
            :NAME_SERVER =>"51.0.12.21",
            :RAM_SIZE =>"94012"
        }
}


FILES_SETTINGS = {

    :main => {
        :NAME =>"main",
        :PRIVATE_IP =>"51.0.1.6",
        :PUBLIC_IP => "46.172.71.53",
        :PUBLIC_PORT => "8090",
        :RAM_SIZE =>"512",
        :FILE_TO_DISK => './tmp/large_disk.vdi',
        :PORTS =>"80",
        :nfs_ip =>"51.1.0.50",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50, 10., 127., 51., 172.82.",
        :domainname =>"files.gex"
    },


    :prod => {
        :NAME =>"prod",
        :PRIVATE_IP =>"51.0.1.6",
        :PRIVATE_MASK =>"255.128.0.0",
        :PUBLIC_IP =>"51.1.1.6",
        :RAM_SIZE =>"512",
        :FILE_TO_DISK => './tmp/large_disk.vdi',
        :nfs_ip =>"51.1.0.50",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50",
        :domainname =>"files.gex"
    }
}


PROXY_SETTINGS = {

    :main => {
        :NAME =>"main",
        :PUBLIC_IP =>"46.172.71.55",
        :PUBLIC_MAC_ADDRESS =>"92:a5:05:ff:f1:d2",
        :GATEWAY =>"46.172.71.33",
        :PRIVATE_IP =>"51.0.1.15",
        :RAM_SIZE =>"3072",
        :nfs_ip =>"51.1.0.50",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50, 10., 127., 51., 172.82.",
        :hostname =>"proxy",
        :domainname =>"proxy.gex"
    },


    :prod => {

        ### prod
        :NAME =>"prod",
        :PUBLIC_IP =>"172.82.184.108",
        :PRIVATE_IP =>"51.0.1.15",
        :PRIVATE_MASK =>"255.0.0.0",
        :PRIVATE_IP6 =>"FD9E:9 E:9 E:0:0:1:0 F:0/64",
        :RAM_SIZE =>"2048",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50",
        :hostname =>"proxy",
        :domainname => "proxy.gex",
        :GATEWAY => "172.82.184.105"
    }

}


OPENVPN_SETTINGS = {


    :main => {

        :NAME =>"main",
        :MACHINE_NAME =>"openvpn",
        :PUBLIC_IP =>"46.172.71.56",
        :PUBLIC_MAC_ADDRESS =>"6e:99:c7:7b:61:0b",
        :PRIVATE_IP =>"51.0.1.8",
        :PRIVATE_MASK =>"255.128.0.0",
        :RAM_SIZE =>"4024",
        :HOST_IP =>"10.2.0.50",
        :dns_server =>"51.0.1.8",
        :nfs_ip =>"51.1.0.50",
        :office_ips =>"46.172.71.50, 10., 127., 51., 172.82.",
        :GATEWAY =>"46.172.71.33",
    },


    :prod => {

        :NAME =>"prod",
        :MACHINE_NAME =>"openvpn",
        :PUBLIC_IP =>"172.82.184.107",
        :PRIVATE_IP =>"51.0.1.8",
        :PRIVATE_MASK =>"255.128.0.0",
        :RAM_SIZE =>"4048",
        :dns_server =>"51.0.1.8",
        :nfs_ip =>"51.1.0.50",
        :office_ips => "46.172.71.50",
        :GATEWAY => "172.82.184.105"

    }

}

WEBPROXY_SETTINGS = {


    :main => {
        :NAME =>"main",
        :PUBLIC_IP =>"10.1.1.2",
        :PRIVATE_IP =>"51.0.1.16",
        :RAM_SIZE =>"2024",
        :nfs_ip =>"51.1.0.50",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50, 10., 127., 51., 172.82.",
        :hostname =>"webproxy",
        :domainname =>"webproxy.devgex.net",
        :domain_aliases =>"webproxy.gex",
        :jwt_secret =>"r7mjurp2vfjsu6611e45",
        :public_ip =>"51.1.1.2",
        :logrotate_files => [{:name =>"nginx", :filepath =>"/opt/openresty/nginx/logs/ *.log",
                              :user =>"vagrant", :group =>"vagrant"}]
    },

    :prod => {
        :NAME =>"prod",

        :PUBLIC_IP =>"104.247.194.117",
        :PRIVATE_IP =>"51.0.1.16",
        :RAM_SIZE =>"3000",
        :nfs_ip =>"51.1.0.50",
        :dns_server =>"51.0.1.8",
        :office_ips =>"46.172.71.50",
        :hostname =>"webproxy",
        :domainname =>"webproxy.galacticexchange.io",
        :domain_aliases =>"webproxy.gex",
        :jwt_secret =>"mjuRP5vfjsu6611e99",
        :public_ip =>"104.247.194.117",
        :logrotate_files => [{:name =>"nginx", :filepath =>"/opt/openresty/nginx/logs/ *.log",
                              :user =>"vagrant", :group =>"vagrant"}]


    }
}

API_SETTINGS = {
    :global_settings => {
        :BOX_IMAGE =>"ubuntu/wily64",
        :BOX_NAME =>"api"
    },

    :main => {
        :NAME =>"main",
        :PUBLIC_IP =>"10.2.1.21",
        :PRIVATE_IP => "51.0.0.21",
        :PRIVATE_MASK =>"255.0.0.0",
        :RAM_SIZE =>"8000"
    },


    :prod => {
        :NAME =>"prod",

        :PUBLIC_IP =>"104.247.194.115",
        :PRIVATE_IP => "51.0.0.21",
        :PRIVATE_MASK =>"255.0.0.0",
        :PRIVATE_IPV6 =>"FD9E:9 E:9 E:0:0:1:c:0/48",
        :RAM_SIZE =>"12000"
    }
}


KAFKA_SETTINGS = {
    :global_settings => {
        :BOX_NAME =>"kafka"
    },

    :main => {
        :NAME =>"main",
        :PRIVATE_IP =>"10.2.0.50",
        :PRIVATE_MASK =>"255.0.0.0",
    },

    :dev => {
        :NAME =>"main",
        :PRIVATE_IP =>"10.2.0.50",
        :PRIVATE_MASK =>"255.0.0.0",
    },

    :prod => {
        :NAME =>"main",
        :PRIVATE_IP =>"10.2.0.52",
        :PRIVATE_MASK =>"255.0.0.0",
    },

}

ALL_SETTINGS = {
    :master_settings => MASTER_SETTINGS,
    :files_settings => FILES_SETTINGS,
    :api_settings => API_SETTINGS,
    :proxy_settings => PROXY_SETTINGS,
    :webproxy_settings => WEBPROXY_SETTINGS,
    :openvpn_settings => OPENVPN_SETTINGS,
}


def add_all_to_hosts
  `rm -f cluster.hosts; touch cluster.hosts`
  ALL_SETTINGS.each do |_, value|
    hostname = value[:global_settings][:BOX_NAME]
    `echo #{value[:main][:PRIVATE_IP]}     #{hostname}.gex  #{hostname} >> cluster.hosts`
  end


  `echo #{API_SETTINGS[:main][:PRIVATE_IP]}     hub.gex  hub >> cluster.hosts`
  `echo \"10.1.1.2 webproxy.devgex.net\">> cluster.hosts`

end
