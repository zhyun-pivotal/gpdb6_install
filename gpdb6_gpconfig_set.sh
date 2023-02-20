#!/bin/bash
### gp_vmem_protect_limit needed calculate refer pysical memory
gpconfig -c gp_vmem_protect_limit -v 1114000
gpconfig -c gp_workfile_compression -v on --masteronly
gpconfig -c max_connections -m 500 -v 1500
gpconfig -c gp_resource_manager -v group
gpconfig -c gp_segment_connect_timeout -v 20min
gpconfig -c gp_fts_probe_timeout -v 60s
gpconfig -c log_duration -v on --masteronly
gpconfig -c log_min_duration_statement -v 1 --masteronly
#gpconfig -c xid_warn_limit -v 300000000 --skipvalidation
#gpconfig -c xid_stop_limit -v 200000000 --skipvalidation
#gpconfig -c gp_external_enable_exec -v on --masteronly
#gpconfig -c log_min_message -v WARNING  --masteronly
#gpconfig -c log_statement -v "'ALL'" --masteronly
#gpconfig -c max_resource_queues -v 16 --masteronly
#gpconfig -c max_appendonly_tables -v 20000 --masteronly
#gpconfig -c gp_resqueue_priority_cpucores_per_segment -m 64 -v 16
#gpconfig -c max_prepared_transactions -v 500
#gpconfig -c superuser_reserved_connections -m 30 -v 3
#gpconfig -c gp_enable_gpperfmon -v 'off'
#gpconfig -c optimizer -v off --masteronly
#gpconfig -c gp_autostat_mode -v 'none'
#gpconfig -c tcp_keepalives_count -v 9
#gpconfig -c tcp_keepalives_idle -v 7200
#gpconfig -c tcp_keepalives_interval -v 75
