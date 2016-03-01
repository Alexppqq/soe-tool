#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_dynamic_tag_conf

#run case
echo "$global_case_name - begin" 
export SPARK_EGO_TAG_PATH=m3

echo "$global_case_name - sbumit job"
# 3 task each run 10s
ca_spark_pyspark_run_sleep  3 10 &>> $global_case_log_dir/tmpOut 
sleep 5

echo "$global_case_name - write report"
ca_assert_file_contain_key_word "$global_case_log_dir/tmpOut" "onStageCompleted: stageId(0)" "job did not finish."

echo "$global_case_name - end" 
ca_recover_spark_dynamic_conf
ca_recover_and_exit 0;

