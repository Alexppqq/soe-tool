#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_priority_conf 

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 20000 &>> $global_case_log_dir/tmpOut

sleep 10
drivername=`ca_get_akka_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
curl -d "" http://$SYM_MASTER_HOST:$global_rest_port/v1/submissions/kill/$drivername 1> $global_case_log_dir/tmpKill 2>> /dev/null
killstatus=`ca_get_kill_driver_status $global_case_log_dir/tmpKill`

echo "$global_case_name - write report"
if [[ -n "$killstatus" ]]; then
   ca_assert_str_eq "$killstatus" "true" "driver cannot be killed."
else
   ca_assert_case_fail "did not get the kill status."
fi

echo "$global_case_name - end" 
ca_recover_and_exit 0;
