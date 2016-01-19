#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
sc_backup_spark_conf;
sc_update_to_spark_env "SPARK_EGO_ENABLE_BLOCKHOST" "true"
sc_restart_master_by_ego_service
sleep 5
ca_add_host_to_blocklist_by_exception
sleep 3
egosh alloc list -ll > $TEST_TOOL_HOME/data/alloc.csv
alloc_id=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "RGROUP,ComputeHosts" 'ALLOC' )
alloc_id=${alloc_id#*:}
ca_check_blocklist_after_submission "$alloc_id" "$SYM_MASTER_HOST"
echo $alloc_id
echo $SYM_MASTER_HOST
egosh alloc unblock -a $alloc_id -n 1 $SYM_MASTER_HOST
ca_check_blocklist_after_submission "$alloc_id" "$SYM_MASTER_HOST"
[[ $? == 0 ]] && echo "remove from block list fail" && ca_recover_and_exit 1; 
#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit  --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &
sleep 10
ca_keep_check_in_file "Job done" "$global_case_log_dir/tmpOut" "1" "40"
res1=$?
ca_kill_process_by_SPARK_HOME "submit" 
sleep 2
ca_check_blocklist_after_submission "$alloc_id" "$SYM_MASTER_HOST"
res2=$?
echo "$global_case_name - write report"
if [[ $res1 == 0 && $res2 == 1 ]]; then
    ca_assert_case_pass
else
    ca_assert_case_fail "Job not done or block list recovery automatically"
fi
#recovery
rm -rf $TEST_TOOL_HOME/data/alloc.csv
sc_restart_master_by_ego_service
sleep 10
echo "$global_case_name - end"
ca_recover_and_exit 0;
