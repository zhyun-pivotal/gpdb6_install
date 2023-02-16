#!/bin/bash

psql -ec "CREATE SCHEMA dba;"
psql -ec "CREATE TABLE dba.service_monitoring(c1 int) distributed by (c1);"
psql -ec "INSERT INTO dba.service_monitoring SELECT generate_series(1,2000);"
psql -ec "SELECT count(*) from dba.service_monitoring;"