#docker run -d --name kafka -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=`docker-machine ip \`docker-machine active\`` --env ADVERTISED_PORT=9092 kafka
#docker run -d --name kafka -h kafka1 -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=kafka1 --env ADVERTISED_PORT=9092 kafka
#docker run -d --name kafka -h kafka1 -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=10.1.0.12 --env ADVERTISED_PORT=9092 kafka
docker run -d --name kafka -p 2181:2181 -p 9092:9092 --env ADVERTISED_HOST=10.1.0.12 --env ADVERTISED_PORT=9092 kafka
