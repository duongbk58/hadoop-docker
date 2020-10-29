### Create table
##### ORC
```sql
create  table wine.name (
user_id string,
name string
)
stored as orc TBLPROPERTIES('transactional'='true');

create table customer_partitioned
 (id int, name string, email string, state string)
 partitioned by (signup date)
 clustered by (id) into 2 buckets stored as orc
 tblproperties("transactional"="true");
```

##### Json
```sql
create external table wine.rating (
review_id string,
user_id string,
business_id string,
stars int,
useful int,
funny int,
cool int,
text string,
date timestamp
)
ROW FORMAT SERDE 'org.apache.hive.hcatalog.data.JsonSerDe'
LOCATION '/user/admin/rating';
```
##### CSV
```sql
CREATE EXTERNAL TABLE IF NOT EXISTS bdp.hv_csv_table
(number INT,country STRING,description STRING,
designation STRING,points INT,price FLOAT,province STRING,
region_1 STRING,region_2 STRING,variety STRING,winery STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs:///user/admin/wine/';
```
##### Merge Statement
```sql
merge into customer_partitioned
 using all_updates on customer_partitioned.id = all_updates.id
 when matched then update set
   email=all_updates.email,
   state=all_updates.state
 when not matched then insert
   values(all_updates.id, all_updates.name, all_updates.email,
   all_updates.state, all_updates.signup);
```