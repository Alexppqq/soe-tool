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
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 30000 &>> $val_case_log_dir/tmpOut &
sleep 10
ca_keep_check_in_file "Driver container state has changed to RUN" "$val_case_log_dir/tmpOut" "1" "40"
driverStatus=`ca_get_nonmaster_driver_status $val_case_log_dir/tmpOut`
echo "$val_case_name - driver status: $driverStatus"
[ -z $driverStatus ] &&   exit 1
drivername=`ca_get_nonmaster_driver_stderr $val_case_log_dir/tmpOut`
echo "$val_case_name - driver name: $drivername" 
[ -z $drivername ] &&   exit 1
ca_keep_check_in_file "Starting task" "/tmp/logs/$drivername" "1" "60"
sleep 3
ca_kill_process_by_SPARK_HOME "executor-id"
stdout=`ca_get_nonmaster_driver_stdout $val_case_log_dir/tmpOut`
ca_keep_check_in_file "Job done" "/tmp/logs/$stdout" "1" "60"
ca_assert_file_contain_key_word /tmp/logs/$stdout "Job done" "executor ego-cluster recover failed"
echo "$val_case_name - write report"
#create case result
echo "$val_case_name - end" 
ca_recover_and_exit 0;
