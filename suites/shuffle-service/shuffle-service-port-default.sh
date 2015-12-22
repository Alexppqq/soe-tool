#!/bin/bash


source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func

ca_filter_only_singleHost    # signle host cluster only, skip if HOST_NUM in ./conf/environment.conf does not equal to 1

source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 


echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"

sc_update_to_spark_default "spark.shuffle.service.port" "7338"
ca_start_shuffle_service_by_script "$val_case_log_dir/tmpOut"

sleep 25
ss_status=`ca_get_shuffle_service_status`
[ -z $ss_status ] && exit 1
lineOutput=`ca_find_by_key_word $val_case_log_dir/tmpOut "7338"`

echo "$val_case_name - write report"
ca_assert_null_ne "$lineOutput" "job not done."

echo "$val_case_name - end" 
ca_recover_and_exit 0;
