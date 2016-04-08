#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 30000 &>> $global_case_log_dir/tmpOut &

sleep 10
ca_keep_check_in_file "State of driver-" "$global_case_log_dir/tmpOut" "1" "40"
driverStatus=`ca_get_akka_driver_status $global_case_log_dir/tmpOut`
echo "$global_case_name - driver status: $driverStatus"
[ -z $driverStatus ] &&   ca_recover_and_exit 1
drivername=`ca_get_akka_driver_name $global_case_log_dir/tmpOut`
echo "$global_case_name - driver name: $drivername" 
[ -z $drivername ] &&   ca_recover_and_exit 1

ca_keep_check_in_file "Starting task" "$SPARK_HOME/work/$drivername/stderr" "1" "40"
sleep 3
ca_kill_process_by_EGO_TOP "vemkd"
[[ $? != 0 ]] && ca_recover_and_exit $?
ca_keep_check_in_file "Job done" "$SPARK_HOME/work/$drivername/stdout" "1" "60"
ca_assert_file_contain_key_word $SPARK_HOME/work/$drivername/stdout "Job done" "vemkd recovery failed"
echo "$global_case_name - write report"
echo "$global_case_name - end" 
ca_recover_and_exit 0;
