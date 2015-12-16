#!/bin/bash

#source env
source ./conf/environment.conf
source ./lib/framework.func
source ./lib/worklaod.func

#calse filter
ca_filter_only_singleHost

#run scenario
source ./scenario/scenario_fifo_conf 

#case name
#val_case_name=submition-client-akka

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $val_case_log_dir/tmpOut &
sleep 25
lineOutput=`ca_find_by_key_word $val_case_log_dir/tmpOut "Job done"|wc -l`
#echo "$val_case_name - job output: $joboutput" #fortest
echo "$val_case_name - write report"
#if [ -z "$joboutput" ]; then
#   fw_report_write_case_result_to_file $val_case_name "Fail" "job cannot finish" 
#elif [ -n "$joboutput" ]; then
#   fw_report_write_case_result_to_file $val_case_name "Pass" "job done"
#fi
ca_assert_num_ge $lineOutput 1 "job not done."
echo "$val_case_name - end" 

ca_recover_and_exit 0;
