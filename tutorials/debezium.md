## Debezium

### Register connector
```shell script
curl -i -X POST -H "Accept:application/json" -H \
 "Content-Type:application/json" http://hadoop-master:8083/connectors/ \
 -d @register-sqlserver.json
```