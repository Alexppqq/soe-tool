#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#make tmp cleanup dir
tmp_cleanup_dir="$val_case_log_dir/tmpDir"
mkdir -p $tmp_cleanup_dir

#config tmp cleanup dir
sc_update_to_spark_default "spark.local.dir" "$tmp_cleanup_dir"
sc_restart_master_by_ego_service
sleep 10

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 60000 &>> $val_case_log_dir/tmpOut &

sleep 10
#kill workload
#ps -ux |grep /gpfs_fqi/zmzhao/sym71/| grep autoTestExamples.jar|grep org.apache.spark.deploy.ego.EGOClusterDriverWrapper|grep -v grep
ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep
appPID=`ps -ux |grep $SPARK_HOME|grep $SAMPLE_JAR|grep -v grep|awk '{print $2}'`
echo $appPID
kill  $appPID

sleep 5
#check clean after app done
cleanup_check_result=`ca_check_cleanup $tmp_cleanup_dir`
echo "return get from check_cleanup_dir: $cleanup_check_result" 
cleanup_stat=`echo $cleanup_check_result|awk -F ';' '{print $1}'`
cleanup_reason=`echo $cleanup_check_result|awk -F ';' '{print $2}'`
echo $cleanup_stat
echo $cleanup_reason

echo "$val_case_name - write report"
ca_assert_str_eq "$cleanup_stat" "success" "$cleanup_reason"

echo "$val_case_name - end" 
if [[ "$cleanup_stat" == "success" ]]; then
   rm -rf $val_case_log_dir/tmpOut
   rm -rf $tmp_cleanup_dir
fi
ca_recover_and_exit 0;
