#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func
source $TEST_TOOL_HOME/lib/workload.func.ad1223
#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fairshare_conf 

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 20000 &>> $global_case_log_dir/tmpOut
sleep 10
driverStatus=`ca_get_akka_driver_status $global_case_log_dir/tmpOut`
echo "$global_case_name - driver status: $driverStatus"
drivername=`ca_get_akka_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
curl -d "" http://$SYM_MASTER_HOST:6066/v1/submissions/kill/$drivername 1> $global_case_log_dir/tmpKill 2>> /dev/null
killstatus=`ca_get_kill_driver_status $global_case_log_dir/tmpKill`
echo $killstatus
if [[ -n "$killstatus" ]]; then
   ca_assert_str_eq "$killstatus" "true" "driver cannot be killed."
fi

#sleep 5
#echo "$global_case_name - write report"
#ca_assert_file_notcontain_key_word "$SPARK_HOME/work/$drivername/stdout" "Job done" "job not be killed."

echo "$global_case_name - end" 
ca_recover_and_exit 0;
