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
echo $SLOTS_PER_HOST
#egosh alloc list -ll > $TEST_TOOL_HOME/data/alloc.csv
#python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv 'RGROUP,ComputeHosts' 'ALLOC' 
ca_assert_num_lt $SLOTS_PER_HOST 8 "free slots are less than 8 ,can't finish this test  case"
job_task=`expr $SLOTS_PER_HOST - 4`
echo "job1 is $job_task"
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR "$job_task" 40000 &>> $val_case_log_dir/tmpOut1  &
sleep 3
$SPARK_HOME/bin/spark-submit --conf spark.master=ego-client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 5 20000 &>> $val_case_log_dir/tmpOut2 &
sleep 20
egosh alloc list -ll > $TEST_TOOL_HOME/data/alloc.csv
alloc_num1=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "ALLOCATED,$job_task" 'RGROUP' )
alloc_num2=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/alloc.csv "ALLOCATED,4" 'RGROUP' )

echo "alloc is $alloc_num2"
#drivername1=`ca_get_nonmaster_driver_name "$val_case_log_dir/tmpOut1"`
#drivername2=`ca_get_nonmaster_driver_name "$val_case_log_dir/tmpOut2"`

echo "$val_case_name - write report"
#ca_assert_str_eq "$alloc_num1" 'RGROUP:ComputeHosts' "slots allocation is not right."
ca_assert_str_eq "$alloc_num2" 'RGROUP:ComputeHosts' "slots allocation is not right."
echo "$val_case_name - end" 
#curl -d "" http://$SYM_MASTER_HOST:6066/v1/submissions/kill/$drivername1 &>> /dev/null
#curl -d "" http://$SYM_MASTER_HOST:6066/v1/submissions/kill/$drivername2 &>> /dev/null
sleep 25
ca_recover_and_exit 0;
