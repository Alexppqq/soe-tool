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
sleep 10
ca_add_host_to_blocklist_by_exception
egosh alloc list -ll > $TEST_TOOL_HOME/data/alloc.csv
alloc_id=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "RGROUP,ComputeHosts" 'ALLOC' )
alloc_id=${alloc_id#*:}
ca_check_blocklist_after_submission "$alloc_id" "red01"
#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit  --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode cluster --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &
sleep 10
ca_keep_check_in_file "State of driver-" "$global_case_log_dir/tmpOut" "1" "40"
drivername=`ca_get_akka_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
[ -z $drivername ] &&   ca_recover_and_exit 1
ca_keep_check_in_file "<EVENT> Spark driver" "$SPARK_HOME/work/$drivername/stderr" "1" "40"
ca_keep_check_in_file "Initial job has not accepted any resources" "$SPARK_HOME/work/$drivername/stderr" "1" "100" 
res1=$?
ca_keep_check_in_file "Starting task" "$SPARK_HOME/work/$drivername/stderr" "1" "10"
res2=$?
echo "$global_case_name - write report"
if [[ $res1 == 0 && $res2 == 1 ]]; then
    ca_assert_case_pass
else
    ca_assert_case_fail "The job can get resource from the host in blocklist or driver start fail in cluster mode"
fi
echo "$global_case_name - end"
#recovery
rm -rf $TEST_TOOL_HOME/data/alloc.csv
ca_kill_process_by_SPARK_HOME "submit"
sc_restart_master_by_ego_service
sleep 10
echo "$global_case_name - end"
ca_recover_and_exit 0;
