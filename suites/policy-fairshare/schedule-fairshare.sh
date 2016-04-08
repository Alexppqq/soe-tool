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
sleep 5
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --conf spark.ego.priority=5 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $SLOTS_PER_HOST 20000 &>> $global_case_log_dir/tmpOut1  &
sleep 3
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --conf spark.ego.priority=5 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR $SLOTS_PER_HOST 10000 &>> $global_case_log_dir/tmpOut2 &
sleep 3
drivername1=`ca_get_akka_driver_name "$global_case_log_dir/tmpOut1"`
drivername2=`ca_get_akka_driver_name "$global_case_log_dir/tmpOut2"`
sleep 30
echo "$global_case_name - get stable alloc tree"
totalDemand=`expr $SLOTS_PER_HOST \* 2`
eachPlanned=`expr $SLOTS_PER_HOST / 2`
eachAssigned=`expr $SLOTS_PER_HOST / 2`
stableTreeTitle="|---root, demand:$totalDemand, assigned:$SLOTS_PER_HOST, planned:$SLOTS_PER_HOST"

echo "debug - check allocaton"
grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:$eachPlanned"|grep "assigned:$eachAssigned"

lineMatched=`grep -A 2 "$stableTreeTitle" $MASTER_LOG|tail -n 3|grep "planned:$eachPlanned"|grep "assigned:$eachAssigned"|wc -l`
#echo $lineMatched

echo "$global_case_name - write report"
if [[ -n $lineMatched ]]; then 
   ca_assert_num_eq "$lineMatched" "2" "slots allocation is not accurate."
else
   ca_assert_case_fail "slots allocation is not right."
   cp $MASTER_LOG $global_case_log_dir/
fi

echo "$global_case_name - end" 
curl -d "" http://$SYM_MASTER_HOST:$global_rest_port/v1/submissions/kill/$drivername1 &>> /dev/null
curl -d "" http://$SYM_MASTER_HOST:$global_rest_port/v1/submissions/kill/$drivername2 &>> /dev/null
ca_recover_and_exit 0;
