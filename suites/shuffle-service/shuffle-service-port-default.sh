#!/bin/bash


source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

ca_filter_only_singleHost    # signle host cluster only, skip if HOST_NUM in ./conf/environment.conf does not equal to 1

source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 


echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"

sc_update_to_spark_default "spark.shuffle.service.port" "7338"
ca_start_shuffle_service_by_script "$val_case_log_dir/tmpOut"
sleep 25
ca_assert_file_contain_key_word $val_case_log_dir/tmpOut "7338" "shuffle service  port 7338 failed"
echo "$val_case_name - write report"
echo "$val_case_name - end" 
ca_kill_process_by_SPARK_HOME "Shuffle"
ca_recover_and_exit 0;
