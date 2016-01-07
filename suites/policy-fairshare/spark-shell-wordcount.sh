#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#case filter
ca_filter_only_singleHost
ca_filter_only_hdfs

#run scenario
source $TEST_TOOL_HOME/scenario/scenario_fairshare_conf

#run case
echo "$global_case_name - begin" 

echo "$global_case_name - name HDFS input/output with random key"
randomKey=`date +%s`
inputFile="/input-${randomKey}.txt"
outputDir="/output-${randomKey}"

echo "$global_case_name - upload data into HDFS as input"
if [[ -f $TEST_TOOL_HOME/data/wordcount_data.txt ]]; then
   $HADOOP_HOME/bin/hadoop fs -copyFromLocal $TEST_TOOL_HOME/data/wordcount_data.txt $inputFile
else
   echo -e "spark on ego\nfor spark and ego" > $TEST_TOOL_HOME/data/wordcount_data.txt
   $HADOOP_HOME/bin/hadoop fs -copyFromLocal $TEST_TOOL_HOME/data/wordcount_data.txt $inputFile 
fi

echo "$global_case_name - input on HDFS"
$HADOOP_HOME/bin/hadoop fs -cat $inputFile

echo "$global_case_name - sbumit job"
ca_spark_shell_run_wordcount "$inputFile" "$outputDir" &>> $global_case_log_dir/tmpOut 
sleep 5


echo "$global_case_name - output on HDFS"
$HADOOP_HOME/bin/hadoop fs -cat $outputDir/part-*
resultHFDS=`$HADOOP_HOME/bin/hadoop fs -cat $outputDir/part-*`
resultExpect="(spark,2)
(on,1)
(ego,2)
(for,1)
(and,1)"

echo "$global_case_name - write report"
if [[ -n $resultHFDS ]]; then
   ca_assert_str_eq "$resultHFDS" "$resultExpect" "result on HDFS is not as expected."
else
   ca_assert_case_fail "no result found on HDFS"
fi

echo "$global_case_name - cleanup HDFS files"
$HADOOP_HOME/bin/hadoop fs -rm -r $inputFile
$HADOOP_HOME/bin/hadoop fs -rm -r $outputDir

echo "$global_case_name - end" 
ca_recover_and_exit 0;

