#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_dynamic_tag_conf 

#run case
echo "$global_case_name - begin" 
export SPARK_EGO_TAG_PATH=m3
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_rest_port --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>>  $global_case_log_dir/tmpOut
sleep 3
drivername=`ca_get_restapi_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
ca_keep_check_in_file "|---m3, demand:" $MASTER_LOG "1" "30"
ca_keep_check_in_file "Job done" "$SPARK_HOME/work/$drivername/stdout" "1" "20"

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$SPARK_HOME/work/$drivername/stdout" "Job done" "job did not finish."

echo "$global_case_name - end" 
ca_recover_spark_dynamic_conf
ca_recover_and_exit 0;
