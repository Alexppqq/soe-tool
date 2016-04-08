#!/bin/bash

#source env
source $TEST_TOOL_HOME/conf/environment.conf
source $TEST_TOOL_HOME/lib/framework.func
source $TEST_TOOL_HOME/lib/workload.func

#calse filter
ca_filter_only_singleHost

#run scenario
sc_backup_spark_conf;
sc_update_to_spark_env "SPARK_EGO_ENABLE_BLOCKHOST" "true"
sc_restart_master_by_ego_service
sleep 10
#setting exception
radomfactor=`date +%s`
sys_user=user$radomfactor
useradd -d /usr/$sys_user -m $sys_user
chmod 555 $SPARK_HOME/work

#run case
sleep 3
echo "$global_case_name - begin" 
echo "$global_case_name - sbumit job"
touch $global_case_log_dir/tmpOut
chmod 777 $global_case_log_dir/tmpOut
su - $sys_user -c "$SPARK_HOME/bin/spark-submit --conf spark.master=spark://$SYM_MASTER_HOST:$global_master_port --deploy-mode client --class job.submit.control.submitSleepTasks $SAMPLE_JAR 3 1000 &>> $global_case_log_dir/tmpOut &"
sleep 3
ca_keep_check_in_file "is added into Block Host list" "$global_case_log_dir/tmpOut" "1" "100" 
res1=$?
ca_keep_check_in_file "Failed to created stdout, stderr redirection files" "$global_case_log_dir/tmpOut" "1" "100" 
res2=$?
ps -ax |grep submit|grep -v grep|grep $SPARK_HOME|awk '{ print $1 }'|xargs kill -9
echo "$global_case_name - write report"
if [[ $res1 == 0 && $res2 == 0 ]]; then
{
    ca_assert_case_pass
}
else
{
    ca_assert_case_fail "Add to block list failed"
}
fi
#recovery
userdel -f  $sys_user
chmod 755 $SPARK_HOME/work
sc_restart_master_by_ego_service
sleep 10
echo "$global_case_name - end"
ca_recover_and_exit 0;
