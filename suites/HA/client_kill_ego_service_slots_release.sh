#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_minimun_conf
sc_update_to_spark_default "spark.deploy.recoveryMode" "FILESYSTEM"
rm -rf /tmp/recovery
mkdir /tmp/recovery
sc_update_to_spark_default "spark.deploy.recoveryDirectory" "/tmp/recovery"
sc_restart_master_by_ego_service
sleep 10
#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode client  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 30000 &>> $global_case_log_dir/tmpOut  &
appID=$! 
sleep 3
ca_keep_check_in_file "Starting task" "$global_case_log_dir/tmpOut" "1" "40"
res1=$?
ca_kill_process_by_SPARK_HOME "\-\-webui\-port"
ca_keep_check_in_file "Master has changed" "$global_case_log_dir/tmpOut" "1" "40"
res2=$?
ca_keep_check_in_file "Release 2 on" "$MASTER_LOG" "1" "40"
res3=$?
ClientName=$( grep "EGO Client registration" $MASTER_LOG|awk '{ print $NF }' )
sleep 3
res4=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $global_case_log_dir/alloc.csv "CLIENT,$ClientName" "ALLOC" )
echo $appID >> $global_case_log_dir/infoWorkload
echo $ClientName
echo $ClientName >> $global_case_log_dir/infoWorkload
sleep 3
echo "$global_case_name - write report"
if [[ $res1 == 0 && $res2 == 0 && $res3 == 0 && $res4 == "" ]]; then
    ca_assert_case_pass
else
    ca_assert_case_fail "master recover to finish job failed"
fi

echo "$global_case_name - end" 

if [[ `ps $appID|wc -l` == 2 ]]; then
   ps $appID 
   kill -9 $appID
fi
egosh service stop $global_es_master
sleep 4
echo $ClientName
egosh client rm $ClientName
mv /tmp/recovery  $global_case_log_dir
ca_recover_and_exit 0;
