#!/bin/sh

#############################################################################################################
#
#  usage: $0 caseListDir/singleCase
#  the script will run all execuable files recursively and give a test report
#    
#############################################################################################################

### source user envrionment 
source ./conf/environment.conf
### source framework library function
source ./lib/framework.func
### source Symphony profile
source $EGO_TOP/profile.platform 
egosh user logon -u Admin -x Admin

### validaty check,  create report and logs dir
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

### create report, export val_report_dir val_test_report
val_report_dir=""
fw_create_report_dir
echo "please find report at $val_report_dir/testReport.txt"

### write report tile, including begin date
fw_write_report_title

### create case list
### Note: all executable file under $1 will be treated as a case
fw_create_case_list $1
echo "please find case list at $val_report_dir/caseList"
echo "please find detail case log under $val_report_dir/logs/"

### run cases
val_case_name="" #take script file name as case name
val_case_result="" #valid value: Pass, Fail, Skip, Timeout
val_case_result_reason=""  #explain reason of result, especially fail reason
cat $val_report_dir/caseList | while read val_case_name; do
    echo "$val_case_name is running."
    if [[ ! -d $val_report_dir/logs/$val_case_name || ! -x $val_report_dir/logs/$val_case_name ]]; then
       mkdir -p $val_report_dir/logs/$val_case_name
    fi
    export val_case_log_dir=$val_report_dir/logs/$val_case_name
    export val_case_name
    SECONDS=0  #system var to trace running time
    while [ "$SECONDS" -le "$CASE_RUNNING_TIMEOUT" ];do  #case timeout, defined by CASE_RUNNING_TIMEOUT
      if [[  -n `echo $val_case_name| grep 'bats$'` ]]; then
         bin/bats --tap $val_case_name 1> $val_case_log_dir/stdout 2> $val_case_log_dir/stderr
      else
         ./$val_case_name  1> $val_case_log_dir/stdout 2> $val_case_log_dir/stderr
      fi
      break
    done
    if [[ "$SECONDS" -gt "$CASE_RUNNING_TIMEOUT" ]]; then
       fw_report_write_case_result_to_file $val_case_name "Timeout" "case runs over ${CASE_RUNNING_TIMEOUT}s."
    elif [[  ! -f $val_case_log_dir/caseResult ]]; then
       fw_report_write_case_result_to_file $val_case_name "Fail" "no result return." 
    fi
    fw_report_write_case_result_to_report
done

# Statistic Case Result
fw_report_calculate_statis

exit 0
