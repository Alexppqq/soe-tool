#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func
#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf 

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
ca_assert_num_lt $SLOTS_PER_HOST 6 "free slots are less than 8 ,can't finish this test  case"
job_task=`expr $SLOTS_PER_HOST - 4`
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR "$job_task" 40000 &>> $val_case_log_dir/tmpOut1  &
sleep 3
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 5 20000 &>> $val_case_log_dir/tmpOut2 &
sleep 3
ca_keep_check_in_file "Starting task" "$val_case_log_dir/tmpOut2" "1" "40"
sleep 3
egosh alloc list -ll > $TEST_TOOL_HOME/data/alloc.csv
#alloc_num1=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "ALLOCATED,$job_task" 'RGROUP' )
alloc_num2=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "ALLOCATED,4" 'RGROUP' )

echo "$val_case_name - write report"
ca_assert_str_eq "$alloc_num2" 'RGROUP:ComputeHosts' "slots allocation is not right."
echo "$val_case_name - end" 
ca_keep_check_in_file "Job done" "$val_case_log_dir/tmpOut2" "1" "60"
rm -rf $TEST_TOOL_HOME/data/alloc.csv
ca_recover_and_exit 0;
