#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_priority_conf

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
# 3 task each run 10s
ca_spark_pyspark_run_sleep  3 10 &>> $val_case_log_dir/tmpOut 
sleep 5
tmpOut=`ca_find_by_key_word $val_case_log_dir/tmpOut "onStageCompleted: stageId(0)"`
lineOutput=`ca_find_by_key_word $val_case_log_dir/tmpOut "onStageCompleted: stageId(0)"|wc -l`
echo $tmpOut
echo $lineOutput

echo "$val_case_name - write report"
ca_assert_num_ge $lineOutput 1 "job not done."

echo "$val_case_name - end" 
ca_recover_and_exit 0;

