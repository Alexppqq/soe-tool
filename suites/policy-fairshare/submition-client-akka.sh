#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fairshare_conf 

#case name
#global_case_name=submition-client-akka

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $global_case_log_dir/tmpOut &
sleep 25
lineOutput=`ca_find_by_key_word $global_case_log_dir/tmpOut "Job done"|wc -l`
#echo "$global_case_name - job output: $joboutput" #fortest
echo "$global_case_name - write report"
#if [ -z "$joboutput" ]; then
#   fw_report_write_case_result_to_file $global_case_name "Fail" "job cannot finish" 
#elif [ -n "$joboutput" ]; then
#   fw_report_write_case_result_to_file $global_case_name "Pass" "job done"
#fi
ca_assert_num_ge $lineOutput 1 "job not done."
echo "$global_case_name - end" 

ca_recover_and_exit 0;
