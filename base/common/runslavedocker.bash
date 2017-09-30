#!/bin/bash


set -x
set -e
set -v

NAME=$1
CLUSTER_UID=$(cat /etc/node/nodeinfo/CLUSTER_UID)
NODE_ID=$(cat /etc/node/nodeinfo/NODE_ID)
NODE_UID=$(cat /etc/node/nodeinfo/NODE_UID)
API_IP=$(cat /etc/node/nodeinfo/API_IP)
PLATFORM_TYPE=$(cat /etc/node/nodeinfo/PLATFORM_TYPE)

if [ $PLATFORM_TYPE == "vbox" ];
then
  ifname="enp0s8" # Ubuntu 16 vagrant second interface
  #ifname="eth1"
else
  ifname=$(route |grep default |awk  ' {print $8} ')
fi

sys_info=$(cat /etc/*-release)
os=''
DHCP_CLIENT=''

#case "$sys_info" in
#  *ubuntu*)
#    os='ubuntu'
#    DHCP_CLIENT='udhcpc'
#    ;;
#  *centos*|*Red\ Hat*)
#    os='centos'
#    DHCP_CLIENT='dhclient'
#  ;;
#esac

cdr2mask ()
{
   # Number of args to shift, 255..255, first non-255 byte, zeroes
   set -- $(( 5 - ($1 / 8) )) 255 255 255 255 $(( (255 << (8 - ($1 % 8))) & 255 )) 0 0 0
   [ $1 -gt 1 ] && shift $1 || shift

 MASK=${1-0}.${2-0}.${3-0}.${4-0}

}


/usr/bin/docker stop $1 | true

nohup /usr/bin/docker start  -a $1 1> /dev/null 2>/dev/null &
#nohup /usr/bin/docker start  -a $1  &
PID=$!
/bin/echo -n "$PID" > /tmp/gex_$NAME.pid

if [[ -z $(curl --connect-timeout 1 -s http://169.254.169.254/1.0/) ]]; then

if [ -n "$2" ]; then
    echo "VAR is set to a non-empty string"
GATEWAY_IP=$(cat /etc/node/nodeinfo/GATEWAY_IP)
NETWORK_MASK=$(cat /etc/node/nodeinfo/NETWORK_MASK)
/usr/local/bin/pipework $ifname -i eth1 $1 "$2/${NETWORK_MASK}@${GATEWAY_IP}"
else	
/usr/local/bin/pipework $ifname -i eth1 $1 udhcpc
fi



fi

LINE=$(grep "$1" /etc/avahi/hosts) || true
if [ -z "$LINE" ]
then
   :
else
   sed -i.bak "/$1/d"  /etc/avahi/hosts
   rm /etc/avahi/hosts.bak
fi

rm /etc/node/nodeinfo/$1-CONTAINER_IP |true

if [[ $(cat /etc/node/nodeinfo/CLOUD_TYPE) == "AWS" ]]; then
  echo "I'm Amazon"
  weave_ip=$(docker exec $1 ip addr  |grep "global ethwe" | awk -F'[/\t\n ]' '{print $6}')
  while [[ ${weave_ip} -eq "" ]]; do
    sleep 5
    weave_ip=$(docker exec $1 ip addr  |grep "global ethwe" | awk -F'[/\t\n ]' '{print $6}')
  done
   echo ${weave_ip} > /etc/node/nodeinfo/$1-CONTAINER_IP
else
  echo "I'm not Amazon"
  docker exec $1 ip addr  |grep "global eth1" | awk -F'[/\t\n ]' '{print $6}' > /etc/node/nodeinfo/$1-CONTAINER_IP
fi

CIP=$(cat /etc/node/nodeinfo/$1-CONTAINER_IP)
HOST_NAME=$(docker exec "$1" hostname)

echo "${CIP} ${HOST_NAME}.local" >> /etc/avahi/hosts


if [[ $1 == h* ]]
then
    echo "Distributed"
else
    line=$(cat '/etc/hosts')
    if [[ $line == *"${HOST_NAME}"* ]]
    then
        sed -i "s/${HOST_NAME}/${CIP} ${HOST_NAME})/g" /etc/hosts
    else
        echo "${CIP} ${HOST_NAME}" >> /etc/hosts
    fi
fi

if [[ ${API_IP} == '46.172.71.53' ]]; then
    API_IP="${API_IP}:8080"
fi
#ip route add ${CIP} dev docker0 | true
curl --data "format=json&clusterID=${CLUSTER_UID}&nodeID=${NODE_UID}&domain=${HOST_NAME}.gex&ip=${CIP}" http://${API_IP}/serviceIp
/usr/sbin/avahi-daemon -r 
echo Runslavedocker completed successfully
