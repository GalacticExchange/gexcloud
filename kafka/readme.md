
# Build

# Run

## Config

* edit docker-compose.$ENV.yml
* set KAFKA_ADVERTISED_HOST_NAME

* run containers
```
docker-compose  -f env/$ENV/docker-compose.yml  up -d

# main
docker-compose  -f env/main/docker-compose.yml  up -d

# prod
docker-compose  --file env/prod/docker-compose.yml up -d


```



####### TO REVIEW

# build

* from
https://github.com/spotify/docker-kafka

```
cd build

docker build -t kafka . 
```

# run

```
docker run -d --name kafka -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=10.1.0.12 --env ADVERTISED_PORT=9092 kafka

docker run -d --name kafka -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=`docker-machine ip \`docker-machine active\`` --env ADVERTISED_PORT=9092 kafka
```

## run with Vagrant

```
vagrant up --provider=docker
```

* connect

```
docker exec -ti kafka /bin/bash
```


* check

```
server.properties
advertised.host.name=<hostname routable by clients>` to `advertised.host.name=<your_master_host(public_ip)>`         advertised.host.name=51.77.39.188
zookeeper.connect=localhost.gex:2181                 to `zookeeper.connect=<your_madter_hostname>:2181`   zookeeper.connect=hadoop-master-10172.gex:2181

```


# Check


# create topic

// default
kafka-topics.sh --zookeeper localhost:2181 --create --topic my1 --replication-factor 1 --partitions 1

// with retention
./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic my2 --partitions 1 --replication-factor 1 --config retention.ms=1000 --config segment.ms=1000  


export KAFKA=`docker-machine ip \`docker-machine active\``:9092
kafka-console-producer.sh --broker-list $KAFKA --topic test


export ZOOKEEPER=`docker-machine ip \`docker-machine active\``:2181
kafka-console-consumer.sh --zookeeper $ZOOKEEPER --topic test

