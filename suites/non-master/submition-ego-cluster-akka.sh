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
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $global_case_log_dir/tmpOut  &
appID=$! 
sleep 3
ca_keep_check_in_file "alloc" "$global_case_log_dir/tmpOut" "1" "40"
driverClientName=`egosh client list -ll| awk -F ',' '/EGOCLIENT/ {print $1}'|sed 's/"//g'`
execClientName=`egosh client list -ll| awk -F ',' '/SPARKDRIVER/ {print $1}'|sed 's/"//g'`
echo $appID >> $global_case_log_dir/infoWorkload
echo $driverClientName
echo $execClientName
echo $driverClientName >> $global_case_log_dir/infoWorkload
echo $execClientName >> $global_case_log_dir/infoWorkload

sleep 3
drivername=`ca_get_nonmaster_driver_stdout $global_case_log_dir/tmpOut`
[ -z $drivername ] && ca_assert_case_fail "no driver name found." && ca_recover_and_exit 1

echo "$global_case_name - driver name: $drivername"  
ca_keep_check_in_file "Job done" "/tmp/logs/$drivername" "1" "40"

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "/tmp/logs/$drivername" "Job done" "ego-cluster sleep job failed"

echo "$global_case_name - end" 
if [[ `ps $appID|wc -l` == 2 ]]; then
   ps $appID 
   kill -9 $appID
   egosh client rm $driverClientName
   egosh client rm $execClientName
fi
ca_recover_and_exit 0;
