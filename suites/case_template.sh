#!/bin/bash

################################################################################################
# usage:
# pleae write case based on this template 
# if you want to try sample in this template, please give it executable right (chmod +x)
################################################################################################

################################################################################################
# Part 1: source cluster environment and library
# ./conf/environment.conf : cluster envirnment defined by user
# ./lib/framework.func : functions used by framework and scenario
# ./lib/worklaod.func : functions used by case
# other library case may needed
################################################################################################
source ./conf/environment.conf
source ./lib/framework.func
source ./lib/worklaod.func

################################################################################################
# Part 2: (Optional) case filter
# if case is designed for certain scenario, such as GPFS or Multiple host,
# you could add a filter to judge if user's envrionment meets your request,
# if not, case will be skiped and exit
# multiple filters was supported
# if not necessary, all case should be designed for single host mode 
################################################################################################
ca_filter_only_singleHost    # signle host cluster only, skip if HOST_NUM in ./conf/environment.conf does not equal to 1
#ca_filter_only_multipleHost  # multiple host cluster only, skip if HOST_NUM in ./conf/environment.conf equals to 1
#ca_filter_only_gpfs          # GPFS only, skip if DIST_FILE_SYSTEM in ./conf/environment.conf does not equal to GPFS(case sensitive)

################################################################################################
# Part 3: set scenario
# any thing related to Spark configuration should be done in scenario
# like to configure certain policy, open debug log or enable suffle servie and so on
# out-of-box scenario in scenario/ dir has covered common conditions. 
# if all of them cannot meet your requirememt, you can add your own one.
# library has supply funcitons about updating spark-env.sh/spark-defualt.conf, which may simplify your coding.
# please use `grep "function" lib/framework.func | grep "sc_"` to find them
#
# out-of-box scenario will
# 1) backup user's original configuration file (spark-env.sh/spark-default.conf/log4j.properties) 
# 2) and then update env/parameters BASED ON the original one instead of creating a new one
# 3) restart spark master to make it take effect
# please use recovery configuration file by function ca_recover_and_exit at the end of the case
# please keep the rule when write your one scenario
#
# any thing related to EGO configuration should also be done in scenario. but it has not be supported by now 
################################################################################################
source ./scenario/scenario_fifo_conf 


################################################################################################
# Part 4: main body of case logic
# a common but not absolute steps is to submit workload and then check the alloc/running status.
# please use "echo" to trace the progress, these info wil be print into stdout under log dir.
# error will be printed into stderr. both stdout/stderr will be stored under logs/ in report dir, separated by case name.
# val_case_name actually is the case script file name, whose value is passed by framework
################################################################################################
echo "$val_case_name - begin" 
echo "$val_case_name - sbumit job"
$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:7077 --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 6000 &>> $val_case_log_dir/tmpOut &
sleep 25
lineOutput=`ca_find_by_key_word $val_case_log_dir/tmpOut "Job done"|wc -l`

################################################################################################
# Part 5: write case result into test report based test output
# case result of assert function is either "Pass" or  "Fail". if fail, a fail reason is needed.
# you should pass 1) value you get 2) value you expect 3) reason if failed to it
# libary supply mulitple asert functions to meet mulitple judgement requriements
# please use `grep "function" lib/worklaod.func | grep "ca_assert"` to find them
#
# besides,
# if case exits unexpectedly before assert, framework will treated it as "Fail" and reason is "no result return"
# "Skip" and "Timeout" are also valid result for a case. 
# "Skip" is introduced in "case filter" session.
# "Timeout" is controled by framework, if case runs longer than CASE_RUNNING_TIMEOUT in ./conf/environment.conf, 
# case process will be killed and case result will be marked as "Timeout" in test report.
# all result, "Pass" "Fail" "Skip" and "Timeout" are case sensitive
################################################################################################
echo "$val_case_name - write report"
ca_assert_num_ge $lineOutput 1 "job not done."

################################################################################################
# Part 6: recover user configuration and exit case
################################################################################################
echo "$val_case_name - end" 
ca_recover_and_exit 0;
