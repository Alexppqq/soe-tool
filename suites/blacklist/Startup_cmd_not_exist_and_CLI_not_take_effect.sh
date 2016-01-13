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
#run case
mv  $SPARK_HOME/bin/exec-wrapper.sh $SPARK_HOME/bin/exec-wrapper.sh.tmp
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.ego.enable.blockhost=false --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &
sleep 2
ca_keep_check_in_file "is added into Block Host list" "$global_case_log_dir/tmpOut" "1" "100" 
res1=$?
ca_keep_check_in_file "Startup command does not exist" "$global_case_log_dir/tmpOut" "1" "100"
res2=$?
echo "$global_case_name - write report"
if [[ $res1 == 0 && $res2 == 0 ]]; then
    ca_assert_case_pass
else
    ca_assert_case_fail "Add to block list failed"
fi
#recovery
ca_kill_process_by_SPARK_HOME "submit"
mv  $SPARK_HOME/bin/exec-wrapper.sh.tmp $SPARK_HOME/bin/exec-wrapper.sh
sc_restart_master_by_ego_service
sleep 10
echo "$global_case_name - end"
ca_recover_and_exit 0;
