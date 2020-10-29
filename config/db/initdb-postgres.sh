#!/bin/bash
export PGPASSWORD=$POSTGRES_PASSWORD
psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'hive'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE hive"
psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'hue'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE hue"
psql -h postgres -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'schema_registry'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE schema_registry"