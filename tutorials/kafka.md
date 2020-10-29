## Kafka 
#### List all topics
```shell script
$KAFKA_HOME/bin/kafka-topics.sh --list \
    --zookeeper hadoop-master:2181,hadoop-slave1:2181,hadoop-slave2:2181
```
#### Consume messages
```shell script
$KAFKA_HOME/bin/kafka-console-consumer.sh \
    --bootstrap-server hadoop-master:9092,hadoop-slave1:9092,hadoop-slave2:9092 \
    --from-beginning \
    --property print.key=true \
    --topic server1.sales.stores
```
#### List all groups
```shell script
 $KAFKA_HOME/bin/kafka-consumer-groups.sh  --list --bootstrap-server hadoop-master:9092,hadoop-slave1:9092,hadoop-slave2:9092
```
#### Reset offsets of Consumer Group
```shell script
$KAFKA_HOME/bin/kafka-consumer-groups.sh --bootstrap-server hadoop-master:9092,hadoop-slave1:9092,hadoop-slave2:9092 \
	--group nifi \
    --reset-offsets \
    --all-topics \
    --to-earliest \
    --execute
```