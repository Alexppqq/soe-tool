#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 30000 &>> $val_case_log_dir/tmpOut &
sleep 3
ca_keep_check_in_file "Starting task" "$val_case_log_dir/tmpOut" "1" "40"
ca_kill_process_by_EGO_TOP "vemkd"
ca_keep_check_in_file "Job done" "$val_case_log_dir/tmpOut" "1" "60"
ca_assert_file_contain_key_word $val_case_log_dir/tmpOut "vemkd has been recovered" "vemkd ego-client recover failed"
echo "$val_case_name - write report"
#create case result
echo "$val_case_name - end" 
ca_recover_and_exit 0;
