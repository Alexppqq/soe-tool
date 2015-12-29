#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost 

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
ca_kill_shuffle_service_process
sleep 3
ca_stop_shuffle_service_by_ego_service
sleep 7
ca_start_shuffle_service_by_ego_service
sleep 10

egosh service list -ll > $TEST_TOOL_HOME/data/service.csv
shuffle=$( python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $TEST_TOOL_HOME/data/service.csv "SERVICE,SPARKSS" 'INST_STATE' )
echo $shuffle
[[ $shuffle != "INST_STATE:RUN"  ]] && echo "start shuffle service failed" && ca_recover_and_exit 1


$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077  --deploy-mode cluster  --class org.apache.spark.examples.SparkTC $SPARK_HOME/lib/spark-examples*  &>> $val_case_log_dir/tmpOut

sleep 5
driverStatus=`ca_get_akka_driver_status $val_case_log_dir/tmpOut`
echo "$val_case_name - driver status: $driverStatus"
drivername=`ca_get_akka_driver_name $val_case_log_dir/tmpOut`
echo "$val_case_name - driver name: $drivername" 

ca_keep_check_in_file "edges" "$SPARK_HOME/work/$drivername/stdout"  "1" "100"
ca_assert_file_contain_key_word $SPARK_HOME/work/$drivername/stdout  "edges" "sparkTC failed"
echo "$val_case_name - write report"
echo "$val_case_name - end" 

rm -rf $TEST_TOOL_HOME/data/service.csv
ca_stop_shuffle_service_by_ego_service
ca_recover_and_exit 0;
