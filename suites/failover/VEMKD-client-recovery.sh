#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 40000 &>> $val_case_log_dir/tmpOut &
sleep 20
ca_kill_process "vemkd"
sleep 60
ca_assert_file_contain_key_word $val_case_log_dir/tmpOut "Job done" "vemkd recover failed"
echo "$val_case_name - write report"
#create case result
echo "$val_case_name - end" 
ca_recover_and_exit 0;