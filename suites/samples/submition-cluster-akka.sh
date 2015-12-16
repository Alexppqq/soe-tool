#!/bin/bash

#source env
source ./conf/environment.conf
source ./lib/framework.func
source ./lib/worklaod.func

#case filter
ca_filter_only_singleHost 

#run scenario
source ./scenario/scenario_fifo_conf 

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode cluster  --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $val_case_log_dir/tmpOut
sleep 10
driverStatus=`ca_get_akka_driver_status $val_case_log_dir/tmpOut`
echo "$val_case_name - driver status: $driverStatus"
drivername=`ca_get_akka_driver_name $val_case_log_dir/tmpOut`
echo "$val_case_name - driver name: $drivername" 
sleep 20
lineOutput=`ca_find_by_key_word $SPARK_HOME/work/$drivername/stdout "Job done"|wc -l`

echo "$val_case_name - write report"
ca_assert_num_ge $lineOutput 1 "job not done."

echo "$val_case_name - end" 
ca_recover_and_exit 0;
