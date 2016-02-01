#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf 

#add consumer 
randomConsumer=con`date +%s`
egosh consumer add /"A$randomConsumer" -e root -a Admin,Guest -g ManagementHosts,ComputeHosts
egosh consumer add /"A$randomConsumer/B" -e root -a Admin,Guest  -g ManagementHosts,ComputeHosts
egosh consumer add /"A$randomConsumer/C" -e root -a Admin,Guest -g ManagementHosts,ComputeHosts
egosh consumer add /"A$randomConsumer/C/D" -e root -a Admin,Guest -g ManagementHosts,ComputeHosts
egosh consumer list|grep $randomConsumer

#spark.ego.client.ttl make consumer can be deleted
sc_update_to_spark_default "spark.ego.client.ttl" "0"
sc_update_to_spark_default "spark.ego.executor.consumer" "/A$randomConsumer/*"

#run shot case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 15000 &>> $global_case_log_dir/tmpOut &

sleep 10
ca_keep_check_in_file  "Starting task 0.0" "$global_case_log_dir/tmpOut" "1" "25"

#get alloc info
egosh alloc list -ll |grep "$randomConsumer" 
egosh alloc list -ll |grep "SPARKDRIVER:" > $global_case_log_dir/allocList

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/allocList" "/A$randomConsumer" "consumer does not take effect"
echo "$global_case_name - end" 
ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep
appPID=`ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep|awk '{print $2}'`
echo $appPID
if [[ -n "$appPID" ]]; then
   kill  $appPID
fi
sleep 5
egosh alloc list -ll |grep "$randomConsumer"
egosh consumer delete /"A$randomConsumer"
ca_recover_and_exit 0;
