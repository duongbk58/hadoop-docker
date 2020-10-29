#!/bin/bash

N=${1:-3}

docker rm -f hadoop-master &> /dev/null
i=1
while [ $i -lt $N ]
do
	docker rm -f hadoop-slave$i &> /dev/null
	i=$(( $i + 1 ))
done

docker rm -f hadoop-slave$i &> /dev/null