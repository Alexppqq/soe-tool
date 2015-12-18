#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
sleep 5
fristPriority=5
secondPriority=10
taskNum=$SLOTS_PER_HOST
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --conf spark.ego.priority=${fristPriority} --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $taskNum 20000 &>> $val_case_log_dir/tmpOut1  &
sleep 3
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --conf spark.ego.priority=${secondPriority} --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $taskNum 10000 &>> $val_case_log_dir/tmpOut2 &
sleep 45

echo "$val_case_name - print stable alloc tree"
totalDemand=`expr $taskNum \* 2`
stableTreeTitle="|---root:FIFO, demand:$totalDemand, assigned:$SLOTS_PER_HOST, planned:$SLOTS_PER_HOST"
fristExpected="/root:FIFO, demand:$taskNum, assigned:$SLOTS_PER_HOST, planned:$SLOTS_PER_HOST, ratio:$fristPriority"
secondExpected="/root:FIFO, demand:$taskNum, assigned:0, planned:0, ratio:$secondPriority"
echo `date`
echo "debug - stable tree"
echo "grep -A 2 '$stableTreeTitle' $MASTER_LOG|tail -n 3"
echo `grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3`
echo "debug - first app right"
echo "grep -A 2 '$stableTreeTitle' $MASTER_LOG|tail -n 3|grep '$fristExpected'"
echo `grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "$fristExpected"`
echo "debug - second app right"
echo "grep -A 2 '$stableTreeTitle' $MASTER_LOG|tail -n 3|grep '$secondExpected'"
echo `grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "$secondExpected"`

#each app should assigned $eachAssigned slots in stable status
firstAllocRight=`grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "$fristExpected"|wc -l`
secondAllocRight=`grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "$secondExpected"|wc -l`

echo "$val_case_name - write report"
lineOutput=`expr $firstAllocRight + $secondAllocRight`
if [[ "$firstAllocRight" == "1" && "$secondAllocRight" == "1" ]]; then
   ca_assert_num_eq "$lineOutput" 2 "slots allocation is not right."
#elif [[ "$firstAllocRight" != "1" || "$firstAllocRight" != "1" ]]; then
else
   ca_assert_num_eq 3 2 "slots allocation is not right."
fi

echo "$val_case_name - end" 
ca_recover_and_exit 0;
