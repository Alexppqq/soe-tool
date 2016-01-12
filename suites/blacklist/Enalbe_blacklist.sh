#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run case
sc_backup_spark_conf;
echo "$global_case_name - begin" 
ca_comment_out_in_spark_default "spark.ego.enable.blockhost"
ca_comment_out_in_spark_env "SPARK_EGO_ENABLE_BLOCKHOST"
sc_update_to_spark_env "SPARK_EGO_ENABLE_BLOCKHOST" "true"
sc_restart_master_by_ego_service
sleep 10
ca_keep_check_in_file "MasterScheduleDelegatorDriver" "$MASTER_LOG" "1" "100"
echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$MASTER_LOG" "Block hosts is enabled" "blacklist enable failed"
echo "$global_case_name - end"
#recovery
ca_recover_and_exit 0;
