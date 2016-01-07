#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf 

#add consumer, rg 
radomfactor=`date +%s`
randomConsumer=con$radomfactor
randomRG=rg$radomfactor
egosh resourcegroup add $randomRG -t Dynamic -s $SLOTS_PER_HOST
egosh rg|grep $randomRG
egosh consumer add /$randomConsumer -e root -a Admin,Guest -g $randomRG
egosh consumer list|grep $randomConsumer

#spark.ego.client.ttl make consumer can be deleted
sc_update_to_spark_default "spark.ego.client.ttl" "0"
sc_update_to_spark_default "spark.ego.driver.consumer" "/$randomConsumer"
sc_update_to_spark_default "spark.ego.driver.plan" "$randomRG"

#run shot case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-cluster --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 10000 &>> $global_case_log_dir/tmpOut &

sleep 5
ca_keep_check_in_file  "Driver container state has changed to RUN" "$global_case_log_dir/tmpOut" "1" "25"

#get alloc info
egosh alloc list -ll 
egosh alloc list -ll |grep "EGOCLIENT:/$randomConsumer" > $global_case_log_dir/allocList

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/allocList" "\"$randomRG\"" "consumer does not take effect"

echo "$global_case_name - end" 
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
egosh resourcegroup delete $randomRG
ca_recover_and_exit 0;
