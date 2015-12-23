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
ca_kill_shuffle_service_process
ca_stop_shuffle_service_by_ego_service
sleep 5
ca_start_shuffle_service_by_ego_service
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077  --deploy-mode cluster  --class org.apache.spark.examples.SparkTC $SPARK_HOME/lib/spark-examples*  &>> $val_case_log_dir/tmpOut
sleep 50
driverStatus=`ca_get_akka_driver_status $val_case_log_dir/tmpOut`
echo "$val_case_name - driver status: $driverStatus"
drivername=`ca_get_akka_driver_name $val_case_log_dir/tmpOut`
echo "$val_case_name - driver name: $drivername" 
sleep 20
ca_assert_file_contain_key_word $SPARK_HOME/work/$drivername/stdout  "edges" "sparkTC failed"
echo "$val_case_name - write report"
echo "$val_case_name - end" 
ca_stop_shuffle_service_by_ego_service
ca_recover_and_exit 0;
