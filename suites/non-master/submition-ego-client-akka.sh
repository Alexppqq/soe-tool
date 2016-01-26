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
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $global_case_log_dir/tmpOut &
appPID=$!
sleep 25

echo "$global_case_name - write report"
ca_assert_file_contain_key_word $global_case_log_dir/tmpOut "Job done" "ego-client sleep job failed"

echo "$global_case_name - end" 
if [[ `ps $appPID|wc -l` == 2 ]]; then
   kill -9 $appPID
fi
ca_recover_and_exit 0;
