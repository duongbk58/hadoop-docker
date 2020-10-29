##Apache Hadoop Cluster Docker Image
It is just for practical or research purpose, do not use it in production environment
but you can follow the instructions in Dockerfile as a guideline to install your own cluster. Hope you guys have a good playground
###Supported OS
```shell script
1. MacOS (tested)
2. Linux (tested)
3. Windows (not yet tested)
```
### Installed Apps
```shell script
1. HDFS
2. Apache Nifi
3. Hortonworks Schema Registry
4. Zookeeper
5. Hue
6. Apache Kafka
7. Debezium
8. Spark
```
### Test Use Case
```shell script
1. You have a Micorost SQL Server that has huge amount of data.
2. You want to build a datawarehouse on Hadoop
3. You think about Apache Hive as your central Datawarehouse (Hive run on Tez)
4. Presto will be your main query engine (Todos)
5. You need an UI to upload file and execute Hive query for Data Analysts, Oh it will be Cloudera Hue
6. You need a simple ETL Tool, drag and drop will be more suitable, Oh it is Apache Nifi
7. You tell your Database admin I need to get CDC Log from database to build a Datawarehouse using these CDC Logs
    because it is the most trusted source
8. How I get these CDC logs and put into Kafka, Debezium will help me on this Yeah!!!
9. Each table has it own schema, how can I store and control its version after my teammate has 
  changed columns' datatype or add more. Hold on I forgot I have Hortonworks Schema Registry
10. Now go to Nifi and connect with Schema Registry and consume messages in Kafka
11. Then do whatever you want with it, Ex: sink these logs to Hive staging tables, ....
```

### Install Guide
#### Build the image
```shell script
git clone project_repo_url
cd project_folder

docker netwrok create hadoop
docker volume create hivemetastore
./build-image.sh
``` 
#### Start Test SQL Server
```shell script
docker run -itd --name sqlserver --net=hadoop \
    -e SA_PASSWORD=Abcd@1234 \
    -e ACCEPT_EULA=y \
    -e MSSQL_AGENT_ENABLED=true \
    -p 1433:1433 \
    microsoft/mssql-server-linux:2017-CU9-GDR2
```
#### Insert data and enable CDC
Go to scripts folder, connect to your SQL Server Server using your favourite client (Navicat, DBeaver)
 and run database scripts
```shell script
1. BikeStores_create.sql
2. BikeStores_data.sql
3. BikeStores_cdc.sql
```

#### Start Docker containers
```shell script
./run-container.sh
docker exec -it hadoop-master ~/hadoop/.start-master.sh
```
### Access your service
```shell script
1. Hue (port: 9090)
2. Nifi (port: 9090)
3. HDFS (port: 9870)
4. Schema Registry (port: 19090)
5. Debexium (port: 8083)
```
### Register your connector
Go co debezium script folder
```shell script
docker cp register-sqlserver.json hadoop-master:/root/register-sqlserver.json
```
Emter running masternode container
```shell script
docker exec -it hadoop-master bash
```
Register
```shell script
curl -i -X POST -H "Accept:application/json" -H \
 "Content-Type:application/json" http://hadoop-master:8083/connectors/ \
 -d @register-sqlserver.json
```
List your kafka topics to see whether it works or not. 
Name of the table will be use to found kafka topic's name
```shell script
$KAFKA_HOME/bin/kafka-topics.sh --list \
    --zookeeper hadoop-master:2181,hadoop-slave1:2181,hadoop-slave2:2181
```
![alt text](Kafka%20Topic.PNG)
### Known Issues
Hard-code something