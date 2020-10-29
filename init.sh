#!/bin/bash
service ssh start
systemctl start mongod
chmod +x ~/hadoop/start-master.sh
chmod +x ~/hadoop/start-slave.sh

# 1 - value to search for
# 2 - value to replace
# 3 - file to perform replacement inline
prop_replace () {
  echo 'replacing target file ' $3
  sed -i -e "s|^$1=.*$|$1=$2|"  $3
}
text_replace () {
  echo 'replacing target file ' $3
  sed -i -e "s|$1|$2|" $3
}
# set kafka props
prop_replace 'broker.id' "${BROKER_ID}" $KAFKA_HOME/config/server.properties
prop_replace 'zookeeper.connect' "${ZOO_CON_STRING}" $KAFKA_HOME/config/server.properties
prop_replace 'bootstrap.servers' "${KAFKA_BROKERS}" $KAFKA_HOME/config/consumer.properties
prop_replace 'advertised.listeners' "PLAINTEXT://${HOSTNAME}:9092" $KAFKA_HOME/config/server.properties
prop_replace 'listeners' "PLAINTEXT://${HOSTNAME}:9092" $KAFKA_HOME/config/server.properties
prop_replace 'rest.advertised.host.name' "${HOSTNAME}" $KAFKA_HOME/config/connect-distributed.properties
prop_replace 'rest.host.name' "${HOSTNAME}" $KAFKA_HOME/config/connect-distributed.properties
text_replace 'CONNECTION_URL' $CON_URL  $HIVE_HOME/conf/hive-site.xml
text_replace 'CONNECTION_PASSWORD' $CON_PASSWORD  $HIVE_HOME/conf/hive-site.xml
text_replace 'CONNECTION_USERNAME' $CON_USERNAME  $HIVE_HOME/conf/hive-site.xml

# set zoo id
echo $ZOO_ID > $ZK_HOME/data/myid
echo -e $ZOO_CONF >>  $ZK_HOME/conf/zoo.cfg
echo -e $WORKERS > $HADOOP_HOME/etc/hadoop/workers
echo -e "${WORKERS}" >> $SPARK_HOME/conf/slaves
bash