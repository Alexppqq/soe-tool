#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func

#case filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
# 3 tasks each run 10000 ms
ca_spark_shell_run_sleep 4 10000 sync &>> $val_case_log_dir/tmpOut 
sleep 5
#lineOutput=`ca_find_by_key_word $val_case_log_dir/tmpOut "onStageCompleted: stageId(0)"|wc -l`
ca_assert_file_contain_key_word $val_case_log_dir/tmpOut "onStageCompleted: stageId(0)" "spark-shell nonmaster sleep job failed"
echo "$val_case_name - write report"
#ca_assert_num_ge $lineOutput 1 "job not done."
echo "$val_case_name - end" 
ca_recover_and_exit 0;

