#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#make tmp cleanup dir
tmp_cleanup_dir="$global_case_log_dir/tmpDir"
mkdir -p $tmp_cleanup_dir

#config tmp cleanup dir
sc_update_to_spark_env "SPARK_EXECUTOR_DIRS" "$tmp_cleanup_dir"
sc_restart_master_by_ego_service
sleep 15

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 60000 &>> $global_case_log_dir/tmpOut &
appPID=$!
echo "$global_case_name - app pid:$appPID"
#wait till task run
sleep 3
ca_keep_check_in_file "Added broadcast_0_piece0" "$global_case_log_dir/tmpOut" "2" "40"
sleep 3

#kill workload
echo "$global_case_name - kill app"
kill  $appPID
sleep 10

#check clean after app done
cleanup_check_result=`ca_check_cleanup $tmp_cleanup_dir`
echo "return get from cleanup_check_result: $cleanup_check_result" 
cleanup_stat=`echo $cleanup_check_result|awk -F ';' '{print $1}'`
cleanup_reason=`echo $cleanup_check_result|awk -F ';' '{print $2}'`
#echo $cleanup_stat
#echo $cleanup_reason

echo "$global_case_name - write report"
ca_assert_str_eq "$cleanup_stat" "success" "$cleanup_reason"

echo "$global_case_name - end" 
#if [[ "$cleanup_stat" == "success" ]]; then
#   rm -rf $global_case_log_dir/tmpOut
#   rm -rf $tmp_cleanup_dir
#fi
ca_recover_and_exit 0;
