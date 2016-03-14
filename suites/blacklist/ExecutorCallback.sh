#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_minimun_conf
sc_update_to_spark_env "SPARK_EGO_ENABLE_BLOCKHOST" "true"
sc_restart_master_by_ego_service
sleep 10
#run case
chmod 000 $SPARK_HOME/bin/exec-wrapper.sh
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &
sleep 2
ca_keep_check_in_file "executorExitCallback" "$MASTER_LOG" "1" "100"
res1=$?
echo "$global_case_name - write report"
if [[ $res1 == 0 ]]; then
    ca_assert_case_pass
else
    ca_assert_case_fail "Add to block list failed"
fi
#recovery
ca_kill_process_by_SPARK_HOME "submit"
chmod 755 $SPARK_HOME/bin/exec-wrapper.sh
sc_restart_master_by_ego_service
sleep 10
echo "$global_case_name - end"
ca_recover_and_exit 0;
