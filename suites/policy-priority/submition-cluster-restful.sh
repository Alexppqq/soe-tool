#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_priority_conf 

#case name
#global_case_name=submition-cluster-restful

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
#$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:6066 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 >>  $global_case_log_dir/stdout 2>> $global_case_log_dir/stderr
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:6066 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>>  $global_case_log_dir/tmpOut
sleep 5
driverStatus=`ca_get_restapi_driver_status $global_case_log_dir/tmpOut`
echo "$global_case_name - driver success to submit: $driverStatus"
drivername=`ca_get_restapi_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
sleep 20
lineOutput=`ca_find_by_key_word $SPARK_HOME/work/$drivername/stdout "Job done"|wc -l`

echo "$global_case_name - write report"
ca_assert_num_ge $lineOutput 1 "job not done."

echo "$global_case_name - end" 
ca_recover_and_exit 0;
