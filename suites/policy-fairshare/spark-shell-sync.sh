#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fairshare_conf

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
ca_spark_shell_run_sleep 3 10000 sync &>> $global_case_log_dir/tmpOut 
sleep 5

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/tmpOut" "onStageCompleted: stageId(0)" "job did not finish."

echo "$global_case_name - end" 
ca_recover_and_exit 0;

