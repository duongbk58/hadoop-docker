FROM ubuntu:18.04

################################
######### INSTALL HDFS #########
################################

ENV HADOOP_VERSION=3.3.0
ENV HADOOP_USER=hadoop
ENV HADOOP_PASSWORD=hadoop
ENV HIVE_USER=hive
ENV HIVE_PASSWORD=hive

RUN apt update && apt install -y ssh openjdk-8-jdk wget curl scala openssl

#RUN usermod -aG hadoop hadoop
RUN mkdir /usr/local/hadoop /usr/local/hive /root/hadoop && \
    mkdir /root/hive
#    chown hadoop:hadoop -R /usr/local/hadoop && \
#    chmod g+rwx -R /usr/local/hadoop && \
#    chown hadoop:hadoop -R /home/hadoop && \
#    chmod g+rwx -R /home/hadoop
#
#USER hadoop
WORKDIR /root
ENV HADOOP_URL=http://mirrors.viethosting.com/apache/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz

RUN wget "$HADOOP_URL"

RUN  tar -xzvf hadoop-$HADOOP_VERSION.tar.gz && \
    mv hadoop-$HADOOP_VERSION/* /usr/local/hadoop && \
    rm hadoop-$HADOOP_VERSION.tar.gz && \
    rm -r hadoop-$HADOOP_VERSION

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV HADOOP_HOME=/usr/local/hadoop
ENV PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin

#copy ssh key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p /usr/local/hadoop/data/dataNode && \
    mkdir -p /usr/local/hadoop/data/nameNode && \
    mkdir $HADOOP_HOME/logs

##########################################
############# INSTALL HUE ################
##########################################
ENV HUE_USER=hue
ENV HUE_PASSWORD=hue
ENV HUE_HOME=/usr/local/hue
RUN apt update && apt install -y ant gcc g++ libkrb5-dev libmysqlclient-dev libssl-dev lsof \
    libsasl2-dev libsasl2-modules-gssapi-mit libsqlite3-dev libtidy-dev libffi-dev \
    libxml2-dev libxslt-dev make libldap2-dev maven python-dev python-setuptools libgmp3-dev
RUN apt install -y git nodejs make gcc g++ curl && \
    mkdir $HUE_HOME && \
    git clone https://github.com/cloudera/hue.git -l $HUE_HOME && \
    useradd -p $(openssl passwd -crypt $HUE_PASSWORD) $HUE_USER
#COPY hue $HUE_HOME

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt -y install nodejs make gcc g++ python-pip && \
    pip install psycopg2-binary
COPY config/hue/pseudo-distributed.ini $HUE_HOME/desktop/conf/pseudo-distributed.ini
RUN cd $HUE_HOME && \
    make apps
RUN chown hue:hue -R $HUE_HOME

###################################
######### INSTALL HIVE ############
###################################

ENV HIVE_VERSION=3.1.2
ENV HIVE_HOME=/usr/local/hive
ENV HIVE_URL=https://mirror.downloadvn.com/apache/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
ENV PATH=$PATH:$HIVE_HOME/bin


RUN wget "$HIVE_URL" && wget "https://jdbc.postgresql.org/download/postgresql-42.2.16.jar"
RUN  tar -xzvf apache-hive-$HIVE_VERSION-bin.tar.gz && \
    mv apache-hive-$HIVE_VERSION-bin/* $HIVE_HOME && \
    rm apache-hive-$HIVE_VERSION-bin.tar.gz && \
    rm -r apache-hive-$HIVE_VERSION-bin && \
    mv ~/postgresql-42.2.16.jar $HIVE_HOME/lib/postgresql-42.2.16.jar

RUN    rm $HIVE_HOME/lib/guava-19.0.jar && \
    cp $HADOOP_HOME/share/hadoop/hdfs/lib/guava-27.0-jre.jar $HIVE_HOME/lib/

##########################################
############ INSTALL ZOOKEEPER ###########
##########################################

ENV ZK_VERSION=3.6.2
ENV ZK_HOME=/usr/local/zookeeper
ENV ZK_URL=https://mirror.downloadvn.com/apache/zookeeper/zookeeper-$ZK_VERSION/apache-zookeeper-$ZK_VERSION-bin.tar.gz
COPY config/zookeeper/* /root/zookeeper/
RUN wget "$ZK_URL" && mkdir -p $ZK_HOME/data && \
    tar -xzvf apache-zookeeper-$ZK_VERSION-bin.tar.gz  && \
    mv apache-zookeeper-$ZK_VERSION-bin/* $ZK_HOME && \
    rm apache-zookeeper-$ZK_VERSION-bin.tar.gz && \
    rm -r apache-zookeeper-$ZK_VERSION-bin && \
    mv ~/zookeeper/zoo.cfg $ZK_HOME/conf/zoo.cfg
# create empty myid file
RUN touch /usr/local/zookeeper/data/myid

############################################
########## INSTALL SCHEMA REGISTRY ###########
############################################

ENV SCHEMA_REGISTRY_VERSION=0.9.1
ENV SCHEMA_REGISTRY_URL=https://github.com/hortonworks/registry/releases/download/$SCHEMA_REGISTRY_VERSION-rc1/hortonworks-registry-$SCHEMA_REGISTRY_VERSION.zip
ENV SCHEMA_REGISTRY_HOME=/usr/local/schema-registry

RUN apt install -y unzip && mkdir $SCHEMA_REGISTRY_HOME && wget "$SCHEMA_REGISTRY_URL" && \
    unzip hortonworks-registry-$SCHEMA_REGISTRY_VERSION.zip && \
    mv hortonworks-registry-$SCHEMA_REGISTRY_VERSION/* $SCHEMA_REGISTRY_HOME && \
    rm hortonworks-registry-$SCHEMA_REGISTRY_VERSION.zip && \
    rm -r hortonworks-registry-$SCHEMA_REGISTRY_VERSION


##########################################
############# INSTALL NIFI ################
##########################################
ENV NIFI_VERSION=1.12.1
ENV NIFI_HOME=/usr/local/nifi
ENV NIFI_URL=https://mirror.downloadvn.com/apache/nifi/$NIFI_VERSION/nifi-$NIFI_VERSION-bin.tar.gz
ENV NIFI_BOOTSTRAP_FILE=$NIFI_HOME/conf/bootstrap.conf
ENV NIFI_PROPS_FILE=$NIFI_HOME/conf/nifi.properties
ENV NIFI_TOOLKIT_PROPS_FILE=$NIFI_HOME/.nifi-cli.nifi.properties

RUN mkdir $NIFI_HOME && wget "$NIFI_URL" && \
    tar -xzvf nifi-$NIFI_VERSION-bin.tar.gz && \
    mv nifi-$NIFI_VERSION/* $NIFI_HOME && \
    rm nifi-$NIFI_VERSION-bin.tar.gz && \
    rm -r nifi-$NIFI_VERSION && \
    wget "https://repo1.maven.org/maven2/org/apache/nifi/nifi-flume-nar/$NIFI_VERSION/nifi-flume-nar-$NIFI_VERSION.nar" && \
    wget "https://repo1.maven.org/maven2/org/apache/nifi/nifi-hive3-nar/$NIFI_VERSION/nifi-hive3-nar-$NIFI_VERSION.nar" && \
    mv nifi-flume-nar-$NIFI_VERSION.nar $NIFI_HOME/lib/nifi-flume-nar-$NIFI_VERSION.nar && \
    mv nifi-hive3-nar-$NIFI_VERSION.nar $NIFI_HOME/lib/nifi-hive3-nar-$NIFI_VERSION.nar


############################################
############# INSTALL KAFKA ################
############################################

ENV KAFKA_VERSION=2.6.0
ENV SCALA_VERSION=2.13
ENV KAFKA_HOME=/usr/local/kafka
ENV KAFKA_URL=https://mirror.downloadvn.com/apache/kafka/$KAFKA_VERSION/kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz

RUN mkdir $KAFKA_HOME && wget "$KAFKA_URL" && \
    wget http://www.scala-lang.org/files/archive/scala-2.13.0-M1.deb && \
    dpkg -i scala-2.13.0-M1.deb && \
    rm scala-2.13.0-M1.deb && \
    tar -xzvf kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && \
    mv kafka_$SCALA_VERSION-$KAFKA_VERSION/* $KAFKA_HOME && \
    rm kafka_$SCALA_VERSION-$KAFKA_VERSION.tgz && \
    rm -r kafka_$SCALA_VERSION-$KAFKA_VERSION && \
    mkdir -p $KAFKA_HOME/plugins && \
    mkdir -p /tmp/kafka-logs && \
    wget -O debezium-connector-mysql.tar.gz https://oss.sonatype.org/service/local/repositories/snapshots/content/io/debezium/debezium-connector-mysql/1.4.0-SNAPSHOT/debezium-connector-mysql-1.4.0-20201027.040616-29-plugin.tar.gz && \
    wget -O debezium-connector-postgres.tar.gz https://oss.sonatype.org/service/local/repositories/snapshots/content/io/debezium/debezium-connector-postgres/1.4.0-SNAPSHOT/debezium-connector-postgres-1.4.0-20201027.040622-29-plugin.tar.gz && \
    wget -O debezium-connector-sqlserver.tar.gz https://oss.sonatype.org/service/local/repositories/snapshots/content/io/debezium/debezium-connector-sqlserver/1.4.0-SNAPSHOT/debezium-connector-sqlserver-1.4.0-20201027.040618-29-plugin.tar.gz && \
    wget -O debezium-connector-mongodb.tar.gz https://oss.sonatype.org/service/local/repositories/snapshots/content/io/debezium/debezium-connector-mongodb/1.4.0-SNAPSHOT/debezium-connector-mongodb-1.4.0-20201027.040629-29-plugin.tar.gz && \
    tar -xzvf debezium-connector-mysql.tar.gz && tar -xzvf debezium-connector-postgres.tar.gz && \
    tar -xzvf debezium-connector-sqlserver.tar.gz && tar -xzvf debezium-connector-mongodb.tar.gz && \
    mv debezium-connector-mysql $KAFKA_HOME/plugins && \
    mv debezium-connector-postgres $KAFKA_HOME/plugins && \
    mv debezium-connector-sqlserver $KAFKA_HOME/plugins && \
    mv debezium-connector-mongodb $KAFKA_HOME/plugins && \
    rm debezium-connector-mysql.tar.gz debezium-connector-postgres.tar.gz debezium-connector-sqlserver.tar.gz debezium-connector-mongodb.tar.gz && \
    rm -rf debezium-connector-mysql debezium-connector-postgres debezium-connector-sqlserver debezium-connector-mongodb

############################################
############# INSTALL SPARK ################
############################################
ENV SPARK_HOME=/usr/local/spark
ENV SPARK_VERSION=3.0.1
ENV SPARK_URL=https://mirror.downloadvn.com/apache/spark/spark-$SPARK_VERSION/spark-$SPARK_VERSION-bin-hadoop3.2.tgz
RUN mkdir $SPARK_HOME && wget "$SPARK_URL" && \
    tar -xzvf spark-$SPARK_VERSION-bin-hadoop3.2.tgz && \
    mv spark-$SPARK_VERSION-bin-hadoop3.2/* $SPARK_HOME && \
    rm spark-$SPARK_VERSION-bin-hadoop3.2.tgz && \
    rm -r spark-$SPARK_VERSION-bin-hadoop3.2

ENV PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin


#ENV HBASE_VERSION=2.3.2
#ENV HBASE_URL=https://mirror.downloadvn.com/apache/hbase/$HBASE_VERSION/hbase-$HBASE_VERSION-bin.tar.gz
#ENV HBASE_HOME=/usr/local/hbase
#
#RUN mkdir $HBASE_HOME && wget "$HBASE_URL" && \
#    tar -xzvf hbase-$HBASE_VERSION-bin.tar.gz && \
#    mv hbase-$HBASE_VERSION/* $HBASE_HOME && \
#    rm hbase-$HBASE_VERSION-bin.tar.gz && \
#    rm -r hbase-$HBASE_VERSION
#ENV PATH=$PATH:$HBASE_HOME/bin

########## Add hadoop config ####################
COPY config/hadoop/* /root/hadoop/

RUN mv ~/hadoop/hadoop-env.sh $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    mv ~/hadoop/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \
    mv ~/hadoop/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv ~/hadoop/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv ~/hadoop/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv ~/hadoop/mapred-env.sh $HADOOP_HOME/etc/hadoop/mapred-env.sh

RUN /usr/local/hadoop/bin/hdfs namenode -format

################### Hive config ###################
COPY config/hive/* /root/hive/
RUN mv ~/hive/hive-env.sh $HIVE_HOME/conf/hive-env.sh && \
    mv ~/hive/hive-site.xml $HIVE_HOME/conf/hive-site.xml

################### Spark config ###################
COPY config/spark/spark-env.sh $SPARK_HOME/conf/spark-env.sh
COPY config/spark/spark-defaults.conf $SPARK_HOME/conf/spark-defaults.conf

################### Kafka config ###################
COPY config/kafka/server.properties $KAFKA_HOME/config/server.properties
COPY config/kafka/connect-distributed.properties $KAFKA_HOME/config/connect-distributed.properties
COPY config/kafka/log4j.properties $KAFKA_HOME/config/log4j.properties
COPY config/kafka/consumer.properties $KAFKA_HOME/config/consumer.properties

################### Nifi Config ####################
COPY config/nifi/nifi.properties $NIFI_HOME/conf/nifi.properties

################### schema registry Config ####################
COPY config/schema-registry/registry.yaml $SCHEMA_REGISTRY_HOME/conf/registry.yaml

COPY init.sh /root/init.sh
CMD /root/init.sh