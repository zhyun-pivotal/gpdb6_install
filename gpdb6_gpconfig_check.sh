#!/bin/bash
### gp_vmem_protect_limit needed calculate refer pysical memory
gpconfig -s gp_vmem_protect_limit
gpconfig -s gp_workfile_compression
gpconfig -s max_connections
gpconfig -s gp_resource_manager
gpconfig -s gp_segment_connect_timeout
gpconfig -s gp_fts_probe_timeout
gpconfig -s log_duration
gpconfig -s log_min_duration_statement
#gpconfig -s xid_warn_limit
#gpconfig -s xid_stop_limit
#gpconfig -s gp_external_enable_exec
#gpconfig -s log_min_message
#gpconfig -s log_statement
#gpconfig -s max_resource_queues
#gpconfig -s max_appendonly_tables
#gpconfig -s gp_resqueue_priority_cpucores_per_segment
#gpconfig -s max_prepared_transactions
#gpconfig -s superuser_reserved_connections
#gpconfig -s gp_enable_gpperfmon
#gpconfig -s optimizer
#gpconfig -s gp_autostat_mode
#gpconfig -s tcp_keepalives_count
#gpconfig -s tcp_keepalives_idle
#gpconfig -s tcp_keepalives_interval
