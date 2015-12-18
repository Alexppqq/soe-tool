#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/worklaod.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fairshare_conf 

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
sleep 5
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --conf spark.ego.priority=5 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $SLOTS_PER_HOST 20000 &>> $val_case_log_dir/tmpOut1  &
sleep 5
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --conf spark.ego.priority=5 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $SLOTS_PER_HOST 10000 &>> $val_case_log_dir/tmpOut2 &
sleep 45
echo "print stable alloc tree"
totalDemand=`expr $SLOTS_PER_HOST \* 2`
eachPlanned=`expr $SLOTS_PER_HOST / 2`
eachAssigned=`expr $SLOTS_PER_HOST / 2`
stableTreeTitle="|---root, demand:$totalDemand, assigned:$SLOTS_PER_HOST, planned:$SLOTS_PER_HOST"
grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:8"|grep "assigned:8"
echo "debug - stable tree"
grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3
echo "debug - planned right"
grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:8"
echo "debug - assigned right"
grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:8"|grep "assigned:8"
#each app should assigned $eachAssigned slots in stable status
lineOutput=`grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:8"|grep "assigned:8"|wc -l`

echo "$val_case_name - write report"
ca_assert_num_eq "$lineOutput" 2 "slots allocation is not right."

echo "$val_case_name - end" 
ca_recover_and_exit 0;
