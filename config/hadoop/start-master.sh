#!/bin/bash

echo -e "Start DFS service\n"
$HADOOP_HOME/sbin/start-dfs.sh
echo -e "Start Yarn service\n"
$HADOOP_HOME/sbin/start-yarn.sh

hdfs dfs -mkdir -p /user/hive/warehouse /user/hbase /user/spark/eventLog
hdfs dfs -chmod g+w /user/hive/warehouse /user/hbase /user/spark/eventLog
hdfs dfs -mkdir -p /tmp/logs
hdfs dfs -chmod g+w /tmp

$HIVE_HOME/bin/init-hive-dfs.sh
echo -e "Init Hive metastore\n"
$HIVE_HOME/bin/schematool -dbType postgres -initSchema
echo -e "Start Zookeeper on master node\n"
$ZK_HOME/bin/zkServer.sh start

# Start zookeeper in datanodes
i=1
while [ $i -lt $NODES ]
do
  ssh-keyscan "hadoop-slave$i" >> $HOME/.ssh/known_hosts
  echo -e "Start Zookeeper on hadoop-slave$i\n"
  ssh "hadoop-slave$i" "${ZK_HOME}/bin/zkServer.sh start; ${KAFKA_HOME}/bin/kafka-server-start.sh -daemon ${KAFKA_HOME}/config/server.properties > /dev/null 2>&1; exit"
  i=$(( $i + 1 ))
done

echo -e "Start Hortonworks schema-registry service\n"
$SCHEMA_REGISTRY_HOME/bootstrap/bootstrap-storage.sh create $SCHEMA_REGISTRY_HOME/conf/registry.yaml &
$SCHEMA_REGISTRY_HOME/bin/registry-server-start.sh $SCHEMA_REGISTRY_HOME/conf/registry.yaml &

echo -e "Start Hive metastore service\n"
hive --service metastore &
echo -e "Start Hiveserver2 service\n"
hive --service hiveserver2 start &
source $HUE_HOME/build/env/bin/activate
hue syncdb --noinput
hue migrate
deactivate
echo -e "Start Hue service\n"
$HUE_HOME/build/env/bin/supervisor &
echo -e "Start Kafka service\n"
$KAFKA_HOME/bin/kafka-server-start.sh -daemon $KAFKA_HOME/config/server.properties > /dev/null 2>&1
echo -e "Create Kafka default topics\n"
$KAFKA_HOME/bin/kafka-topics --create --zookeeper $ZOO_CON_STRING --topic connect-configs --replication-factor 3 --partitions 1 --config cleanup.policy=compact
$KAFKA_HOME/bin/kafka-topics --create --zookeeper $ZOO_CON_STRING --topic connect-offsets --replication-factor 3 --partitions 1 --config cleanup.policy=compact
$KAFKA_HOME/bin/kafka-topics --create --zookeeper $ZOO_CON_STRING --topic connect-status --replication-factor 3 --partitions 1 --config cleanup.policy=compact
$KAFKA_HOME/bin/connect-distributed.sh $KAFKA_HOME/config/connect-distributed.properties &

echo -e "Start Nifi service\n"
$NIFI_HOME/bin/nifi.sh start
echo -e "Start Spark service\n"
$SPARK_HOME/sbin/start-all.sh &
