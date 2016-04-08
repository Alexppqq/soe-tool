#!/bin/bash 

#############################################################################################################
#
#  usage: $0 caseListDir/singleCase
#    
#############################################################################################################

### source user envrionment 
source ./conf/environment.conf
### source framework library function
source ./lib/framework.func
### parameter validaty check,  create report and logs dir
if [[ -z "$1" || -n $2 ]]; then
   echo " Usage: There're two modes to run this tools."
   echo "        Regression  Mode:  $0 Case_Group_Dir"
   echo "                           such as: $0 suites"
   echo "        Single file Mode:  $0 Script_Case_File"
   echo "                           such as: $0 suites/xx.sh"
   echo "                                    $0 suites/xx.bats"
   echo "        please configure conf/environment.conf before regression"
   exit 1
elif [[ ! -x $1 ]]; then
   echo "please make sure $1 has executale right."
   exit 1
fi
### environment check
fw_env_check
export global_master_port
export global_rest_port
export global_es_master
export global_es_shuffle
fw_get_config
### source EGO profile
source $EGO_TOP/profile.platform

### ego environment check
global_ego_version=`fw_get_ego_version`
export global_ego_version
if [[ -z $global_ego_version ]]; then
   echo "EGO version is missed. please make sure EGO works well."
   exit 1
elif [[ $global_ego_version != 3.1.?.? && $global_ego_version != 3.3.?.? ]]; then
   echo "EGO version $global_ego_version is not supported."
   exit 1
#else
#   echo "EGO version: $global_ego_version"
fi
### spark command check
global_spark_version=`fw_get_spark_version`
if [[ -z $global_spark_version ]]; then
   echo "Spark version is missed. please make sure Spark is well installed."
   exit 1
#else
#   echo "Spark version: $global_spark_version"
fi
### hadoop command check
global_hadoop_version=`fw_get_hadoop_version`
if [[ -z $global_hadoop_version ]]; then
   echo "Hadoop version is missed. please make sure Hadoop is well installed."
   exit 1
#else
#   echo "Hadoop version: $global_hadoop_version"
fi
### soe command check
global_soe_version=`fw_get_spark_on_ego_version`
if  [[ -z $global_soe_version ]]; then
   echo "Spark on EGO version is missed. please make sure SparkOnEgo Plugin is well installed."
   exit 1
elif [[ "$global_soe_version" != Build* ]]; then
   echo "Spark on EGO version is wrong. please make sure SparkOnEgo Plugin is well installed."
   exit 1
#else
#   echo "SparkOnEgo version: $global_soe_version"
fi

#info user the version message together, 
#hadoop is skipped since it's only optional
echo "Spark on Ego Automation tool is running on:"
echo "      EGO version: $global_ego_version"
echo "      Spark version: $global_spark_version"
echo "      SparkOnEgo version: $global_soe_version"
#   echo "Hadoop version: $global_hadoop_version" 

### create report, export global_report_dir global_test_report
global_report_dir=""
fw_create_report_dir
echo "please find report at $global_report_dir/testReport.txt"

### write report tile, including begin date
fw_report_write_title

### create case list
### Note: all executable file under $1 will be treated as a case
fw_create_case_list $1
echo "please find case list at $global_report_dir/caseList"
echo "please find detail case log under $global_report_dir/logs/"

### run cases
global_case_name="" #take script file name as case name
global_case_result="" #valid value: Pass, Fail, Skip, Timeout
global_case_result_reason=""  #explain reason of result, especially fail reason

global_case_pass=0
global_case_fail=0
global_case_skip=0
global_case_timeout=0

cat $global_report_dir/caseList | while read global_case_name; do
    echo -n "run $global_case_name "
    if [[ ! -d $global_report_dir/logs/$global_case_name || ! -x $global_report_dir/logs/$global_case_name ]]; then
       mkdir -p $global_report_dir/logs/$global_case_name
    fi
    export global_case_log_dir=$global_report_dir/logs/$global_case_name
    export global_case_name
    if [[  -n `echo $global_case_name| grep 'bats$'` ]]; then
       bin/bats --tap $global_case_name 1> $global_case_log_dir/stdout 2> $global_case_log_dir/stderr
    else
       SECONDS=0 #system var to trace running time
       ./$global_case_name  1> $global_case_log_dir/stdout 2> $global_case_log_dir/stderr &
       casePid=$!
#       casePgid=$(ps opgid= $casePid)
#       ps fj
    fi
    while [[ -n `ps $casePid|grep $casePid` && "$SECONDS" -le "$CASE_RUNNING_TIMEOUT" ]]; do
      #echo -n "${SECONDS} -"; ps $casePid|grep $casePid
      if [ $(($SECONDS%10)) = '0' ]; then
         echo -n "."
      fi 
      sleep 1;
    done
    if [[ "$SECONDS" -gt "$CASE_RUNNING_TIMEOUT" ]]; then
       echo " timeout."
       kill -9 $casePid
       #below 3 sentences kill workload for ego-cluster mode, rarely to use if run ego-cluster workload with &, so comment out it
       #kill -9 `cat $global_case_log_dir/infoWorkload|awk 'NR==1 {print}' `
       #egosh client rm `cat $global_case_log_dir/infoWorkload|awk 'NR==2 {print}' `
       #egosh client rm `cat $global_case_log_dir/infoWorkload|awk 'NR==3 {print}' `
       sc_recover_spark_conf
       fw_report_save_case_result_in_file $global_case_name "Timeout" "case runs over ${CASE_RUNNING_TIMEOUT}s."
    elif [[  ! -f $global_case_log_dir/caseResult ]]; then
       fw_report_save_case_result_in_file $global_case_name "Fail" "no result return." 
       echo " error."
    else
       echo " done."
    fi
    fw_report_write_case_result_to_report
done

# Statistic Case Result
fw_report_calculate_statis
fw_report_create_html_report

# return exit code to Jenkins build job if the code is not zero, the build job would be failure build. otherwise, it will be successful build.
if [ "$global_case_pass_rate" != "100%" ]; then
  exit 1
else
  exit 0
fi
