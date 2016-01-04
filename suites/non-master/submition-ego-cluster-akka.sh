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
#$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 >>  $val_case_log_dir/stdout 2>> $val_case_log_dir/stderr
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $val_case_log_dir/tmpOut
sleep 10
driverStatus=`ca_get_nonmaster_driver_status $val_case_log_dir/tmpOut`
echo "$val_case_name - driver status: $driverStatus"
[ -z $driverStatus ] &&   exit 1
#driverid=`ca_get_nonmaster_driver_id $val_case_log_dir/tmpOut`
drivername=`ca_get_nonmaster_driver_stdout $val_case_log_dir/tmpOut`
echo "$val_case_name - driver name: $drivername" 
[ -z $drivername ] &&   exit 1
sleep 20
#lineOutput=`ca_find_by_key_word /tmp/logs/$drivername "Job done"|wc -l`
ca_assert_file_contain_key_word /tmp/logs/$drivername "Job done" "ego-cluster sleep job failed"
echo "$val_case_name - write report"
#ca_assert_num_ge $lineOutput 1 "job not done."

echo "$val_case_name - end" 
ca_recover_and_exit 0;
