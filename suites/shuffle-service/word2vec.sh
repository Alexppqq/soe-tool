#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost
ca_filter_only_hdfs
#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fifo_conf 

#case name
#val_case_name=submition-client-akka

#run case
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
randomKey=`date +%s`
inputFile="/input-${randomKey}.txt"
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $TEST_TOOL_HOME/data/text8_lines $inputFile
#verify input
$HADOOP_HOME/bin/hadoop fs -ls $inputFile

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


$SPARK_HOME/bin/spark-submit --driver-memory 4g $SPARK_HOME/examples/src/main/python/mllib/word2vec.py $inputFile &>>$val_case_log_dir/tmpOut
ca_keep_check_in_file "taiwan" "$val_case_log_dir/tmpOut"  "1" "100"
ca_assert_file_contain_key_word $val_case_log_dir/tmpOut "taiwan" "word2vec failed"
echo "$val_case_name - write report"
echo "$val_case_name - end" 


ca_stop_shuffle_service_by_ego_service
$HADOOP_HOME/bin/hadoop fs -rm -r $inputFile &>> /dev/null
rm -rf $TEST_TOOL_HOME/data/service.csv
ca_recover_and_exit 0;
