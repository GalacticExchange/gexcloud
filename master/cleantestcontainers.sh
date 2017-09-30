#!/bin/sh
sudo rm -rf /etc/systemd/system/*master-99*
sudo rm -rf /etc/systemd/system/*master-99*
sudo rm -rf /etc/systemd/system/*consul-99*
sudo systemctl daemon-reload
sudo docker kill  $(sudo docker ps -q -a --filter "name=99")
sudo docker rm -f $(sudo docker ps -q -a --filter "name=99")
sudo docker exec openvpn bash -c 'rm -rf /data/consul/consul99'
rm -rf /tmp/*999*
