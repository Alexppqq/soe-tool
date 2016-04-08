#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#add resource group 
radomfactor=`date +%s`
randomConsumer=con$radomfactor
randomRG=rg$radomfactor
egosh resourcegroup add $randomRG -t Dynamic -s $SLOTS_PER_HOST
egosh rg|grep $randomRG
egosh consumer add /$randomConsumer -e root -a Admin -g $randomRG
egosh consumer list|grep $randomConsumer

#config resource group, disable HA, for spark.ego.client.ttl make resource group cannot be deleted
ca_comment_out_in_spark_default "spark.deploy.recoveryMode"
ca_comment_out_in_spark_default "spark.deploy.recoveryDirectory"
sc_update_to_spark_default "spark.ego.driver.consumer" "/$randomConsumer"
sc_update_to_spark_default "spark.ego.driver.plan" "$randomRG"

#restart service to make config take effect
sc_restart_master_by_ego_service
sleep 3
ca_keep_check_in_file "$randomRG" "$MASTER_LOG" "1" "15"

#run shot case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
ps ux|grep Master
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode cluster --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &

sleep 15
#get alloc info
egosh alloc list -ll
egosh alloc list -ll |grep "SPARK_RESMGR" > $global_case_log_dir/allocList

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/allocList" "$randomRG" "resource group $randomRG does not take effect"

echo "$global_case_name - end" 
appPID=`ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep|awk '{print $2}'`
echo $appPID
if [[ -z "$appPID" ]]; then
   egosh service stop $global_es_master
else
   kill  $appPID
   sleep 5
   egosh service stop $global_es_master
fi
sleep 5
egosh alloc list -ll |grep "SPARK_RESMGR"
egosh consumer delete /$randomConsumer
egosh resourcegroup delete $randomRG
ca_recover_and_exit 0;
