#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#add consumer 
randomConsumer=con`date +%s`
egosh consumer add /$randomConsumer -e root -a Admin -g ManagementHosts,ComputeHosts 
egosh consumer list|grep $randomConsumer
#egosh consumer view /$randomConsumer

#config consumer, disable HA, for spark.ego.client.ttl make consumer cannot be deleted
ca_comment_out_in_spark_default "spark.deploy.recoveryMode"
ca_comment_out_in_spark_default "spark.deploy.recoveryDirectory"
sc_update_to_spark_default "spark.ego.driver.consumer" "/$randomConsumer"

#restart service to make config take effect
sc_restart_master_by_ego_service
sleep 3
ca_keep_check_in_file "/$randomConsumer" "$MASTER_LOG" "1" "15"

#run shot case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode cluster --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &

sleep 15
#get alloc info
egosh alloc list -ll |grep "SPARK_RESMGR" > $global_case_log_dir/allocList

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/allocList" "/$randomConsumer" "consumer does not take effect"

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
ca_recover_and_exit 0;
