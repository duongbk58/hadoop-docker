#!/bin/sh
/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -i /home/scripts/database/BikeStores_drop.sql
/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -i /home/scripts/database/BikeStores_create.sql
/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -i /home/scripts/database/BikeStores_data.sql
/opt/mssql-tools/bin/sqlcmd -U sa -P $SA_PASSWORD -i /home/scripts/database/BikeStores_cdc.sql
