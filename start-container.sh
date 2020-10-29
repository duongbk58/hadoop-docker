#!/bin/bash

# the default node number is 3
N=${1:-3}

# Generate workers file for hadoop and zk config
workers=""
zk_cfg=""
zk_string="hadoop-master:2181"
i=1
kafka_brokers="hadoop-master:9092"
while [ $i -lt $N ]
do
  name="hadoop-slave$i"
  workers="${workers}${name}\n"
  i=$(( $i + 1 ))
  zk_cfg="${zk_cfg}server.${i}=${name}:2888:3888\n"
  zk_string="${zk_string},${name}:2181"
  kafka_brokers="${kafka_brokers},${name}:9092"
done

# start hadoop master container
docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop \
                -p 9870:9870 -p 9090:9090 -p 19090:19090 \
                -p 8000:8000 -p 8083:8083 \
                -p 10002:10002 -p 7077:7077 \
                -p 9083:9083 -p 60010:60010 \
                -p 8088:8088 -p 8081:8081 \
                -e KAFKA_BROKERS=$kafka_brokers \
                -e NODES=$N -e CON_URL=jdbc:postgresql://postgres:5432/hive \
                -e BROKER_ID=1 -e CON_PASSWORD=123456 \
                -e CON_USERNAME=postgres \
                -e WORKERS=$workers \
                -e ZOO_CON_STRING=$zk_string \
                -e ZOO_ID=1 \
                -e ZOO_CONF=$zk_cfg \
                --name hadoop-master \
                --hostname hadoop-master \
                hadoop:1.0
# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	zk_num=$(( $i + 1 ))
	docker run -itd \
	                --net=hadoop \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                -e BROKER_ID=$zk_num \
	                -e NODES=$N \
	                -e KAFKA_BROKERS=$kafka_brokers \
	                -e WORKERS=$workers \
	                -e ZOO_CON_STRING=$zk_string \
	                -e ZOO_ID=$zk_num \
	                -e ZOO_CONF=$zk_cfg \
	                hadoop:1.0
	i=$(( $i + 1 ))
done
# Start database
docker rm -f postgres &> /dev/null
echo "start postgres container..."
docker run -d \
    --name postgres \
    -p 5432:5432 \
    --net=hadoop \
    -e POSTGRES_PASSWORD=123456 \
    -e PGDATA=/var/lib/postgresql/data/pgdata \
    -v hivemetastore:/var/lib/postgresql/data \
    -v $PWD/config/db/initdb-postgres.sh:/root/initdb-postgres.sh \
    postgres
docker exec postgres  bash -c 'chmod +x /root/initdb-postgres.sh && /root/initdb-postgres.sh'