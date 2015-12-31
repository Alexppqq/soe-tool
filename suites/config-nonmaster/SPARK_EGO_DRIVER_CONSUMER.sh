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
egosh consumer add /$randomConsumer -e root -a Admin,Guest -g ManagementHosts 
egosh consumer view /$randomConsumer

#spark.ego.client.ttl make consumer can be deleted
sc_update_to_spark_default "spark.ego.client.ttl" "0"
sc_update_to_spark_env "SPARK_EGO_DRIVER_CONSUMER" "/$randomConsumer"

#run shot case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-cluster --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 10000 &>> $val_case_log_dir/tmpOut &

sleep 10
ca_keep_check_in_file  "Driver container state has changed to RUN" "$val_case_log_dir/tmpOut" "1" "25"

#get alloc info
egosh alloc list -ll 
egosh alloc list -ll |grep "EGOCLIENT:/$randomConsumer" > $val_case_log_dir/allocList

echo "$val_case_name - write report"
ca_assert_file_contain_key_word "$val_case_log_dir/allocList" "\"/$randomConsumer\"" "consumer does not take effect"

echo "$val_case_name - end" 
appPIDs=`ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep|awk '{print $2}'`
echo $appPIDs
if [[ -n "$appPIDs" ]]; then
   for appPID in $appPIDs
   do
      kill -9 $appPID
   done
fi
sleep 5
egosh alloc list -ll |grep "$randomConsumer"
egosh consumer delete /$randomConsumer
ca_recover_and_exit 0;
