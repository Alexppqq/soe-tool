#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func
#case filter
ca_filter_only_singleHost
ca_filter_only_hdfs

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_nonmaster_conf

#run case
echo "$global_case_name - begin" 
echo "$global_case_name - make random HDFS input/output"
randomKey=`date +%s`
inputFile="/input-${randomKey}.txt"
outputDir="/output-${randomKey}"
$HADOOP_HOME/bin/hadoop fs -copyFromLocal $SPARK_HOME/data/mllib/pagerank_data.txt $inputFile
#verify input
$HADOOP_HOME/bin/hadoop fs -ls $inputFile

echo "$global_case_name - sbumit job"
ca_spark_shell_run_wordcount $inputFile $outputDir &>> $global_case_log_dir/tmpOut 
sleep 5
ca_assert_file_exist_in_hdfs "$outputDir" "part-" "spark shell run wordcount can't find output file "
#tmpOut=`$HADOOP_HOME/bin/hadoop fs -ls $outputDir| grep "part-"`
#lineOutput=`$HADOOP_HOME/bin/hadoop fs -ls $outputDir| grep "part-"|wc -l`
#echo $tmpOut
#echo $lineOutput

echo "$global_case_name - write report"
#ca_assert_num_ge $lineOutput 1 "job not done."

echo "$global_case_name - cleanup HDFS files"
$HADOOP_HOME/bin/hadoop fs -rm -r $inputFile &>> /dev/null
$HADOOP_HOME/bin/hadoop fs -rm -r $outputDir &>> /dev/null

echo "$global_case_name - end" 
ca_recover_and_exit 0;

