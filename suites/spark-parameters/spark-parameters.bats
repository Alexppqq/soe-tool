#!/usr/bin/env bats

load $TEST_TOOL_HOME/test/helpers/assertions/all.bash
load $TEST_TOOL_HOME/scenario/scenario_minimun_conf
load $TEST_TOOL_HOME/lib/workload.func

setup() {
  SPARK_TMP_FILE="${TEST_TOOL_HOME}/test/tmp/case_spark_shell.out"
  EGO_TMP_FILE="${TEST_TOOL_HOME}/test/tmp/ego_cmd.out"
  touch $SPARK_TMP_FILE $EGO_TMP_FILE
}

teardown() {
  [ -f $SPARK_TMP_FILE ] && [ -f $EGO_TMP_FILE ] && rm -f $SPARK_TMP_FILE $EGO_TMP_FILE
  unset SPARK_TMP_FILE EGO_TMP_FILE
}

@test "set spark.ego.executor.idle.timeout=10 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				--deploy-mode client \
                                --class spark.parameter.test.parameterTest \
                                $TEST_TOOL_HOME/lib/autoTestExamples.jar "spark.ego.executor.idle.timeout=10"
  assert_contains "${output}" "0: key=spark.ego.executor.idle.timeout value=10"
}

@test "set spark.ego.executor.idle.timeout=10 via cmd line only effect for spark shell or pyspark command" {
  sc_update_to_spark_default "spark.ego.executor.idle.timeout" 10
  ca_spark_shell_run_sleep 1 3 sync "EGODeployScheduler: Cleanup executor" >> $SPARK_TMP_FILE 3>&1
  ca_find_keyword_timeout $SPARK_TMP_FILE "onStageCompleted: stageId" 30
  local start_time=$(grep 'onStageCompleted: stageId' ${SPARK_TMP_FILE} | awk '{print $(NF-6)}')
  ca_find_keyword_timeout $SPARK_TMP_FILE "EGODeployScheduler: Cleanup executor" 30
  local end_time=$(grep 'EGODeployScheduler: Cleanup executor' ${SPARK_TMP_FILE} | awk '{print $1}')
  local val=$(( $end_time - $start_time ))
  [ $val -ge 10000 ] && [ $val -le 12000 ] || [ $status -eq 0 ]
}

@test "set spark.ego.executor.slots.max=10 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				   --deploy-mode client \
                                   --class spark.parameter.test.parameterTest \
                                   $TEST_TOOL_HOME/lib/autoTestExamples.jar "spark.ego.executor.slots.max=10"
  assert_contains "${output}" "0: key=spark.ego.executor.slots.max value=10"
}

@test "spark.ego.executor.slots.max=5" {
  local uuid=$(uuidgen -t)
  sc_update_to_spark_default "spark.ego.app.name" $uuid
  sc_restart_master_by_script
  local ego_client_name="SPARK_RESMGR:${uuid}"
  $SPARK_HOME/bin/spark-submit --master spark://${SYM_MASTER_HOST}:7077 \
			       --deploy-mode cluster \
                               --class spark.parameter.test.parameterTest \
                               $TEST_TOOL_HOME/lib/autoTestExamples.jar 5 60000
  egosh alloc list -s -ll >> $EGO_TMP_FILE 3>&1
  local driver_id=$(ca_get_driver_id $BATS_OUT)
  [ -z $driver_id ] && echo $driver_id && return 1
  local ego_acti=$(python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $EGO_TMP_FILE "CLIENT,${ego_client_name}" "ACTI")
  local ego_alloc=$(python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $EGO_TMP_FILE "CLIENT,${ego_client_name}" "ALLOCATED")
  [ ${ego_acti:5:${#ego_acti}} -eq 1 ] || echo "${ego_acti}"
  [ ${ego_alloc:10:${#ego_alloc}} -ge 1 ] || echo "${ego_alloc}"
  [ ${ego_alloc:10:${#ego_alloc}} -le 5 ] || echo "${ego_alloc}"

  ca_kill_spark_app "$driver_id" "$SYM_MASTER_HOST:6066"
}

@test "spark.ego.app.name=UUID, spark master would read it once from conf file when startup" {
  local uuid=$(uuidgen -t)
  sc_update_to_spark_default "spark.ego.app.name" $uuid
  sc_restart_master_by_script
  local ego_client_nameA="SPARK_RESMGR:${uuid}"
  $SPARK_HOME/bin/spark-submit --deploy-mode cluster \
                               --class spark.parameter.test.parameterTest \
                               $TEST_TOOL_HOME/lib/autoTestExamples.jar 1 60000 >> $SPARK_TMP_FILE 3>&1
  egosh alloc list -s -ll >> $EGO_TMP_FILE 3>&1
  local driver_id=$(ca_get_driver_id $SPARK_TMP_FILE)
  local ego_client_nameB=$(python $TEST_TOOL_HOME/lib/ego/get_ego_alloc_val.py $EGO_TMP_FILE "CLIENT,${ego_client_nameA}" "CLIENT")
  assert_equal "$ego_client_nameA" "${ego_client_nameB:7:${#ego_client_nameB}}"
  ca_kill_spark_app "$driver_id" "$SYM_MASTER_HOST:6066"
  [ $? -eq 1 ] || echo "kill job failure"
}

@test "set spark.ego.priority=100 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				   --deploy-mode client \
                                   --class spark.parameter.test.parameterTest \
                                   $TEST_TOOL_HOME/lib/autoTestExamples.jar "spark.ego.priority=100"
  assert_contains "${output}" "key=spark.ego.priority value=100"
}

@test "set spark.ego.submit.file.replication=1 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				   --deploy-mode client \
                                   --class spark.parameter.test.parameterTest \
                                   $TEST_TOOL_HOME/lib/autoTestExamples.jar "spark.ego.submit.file.replication=1"
  assert_contains "${output}" "key=spark.ego.submit.file.replication value=1"
}

@test "set spark.ego.distribute.files=true in client mode" {
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				   --deploy-mode client \
                                   --class spark.parameter.test.parameterTest \
                                   $TEST_TOOL_HOME/lib/autoTestExamples.jar "spark.ego.distribute.files=true"
  assert_contains "${output}" "key=spark.ego.distribute.files value=true"
}

@test "set spark.ego.distribute.files=true in cluster mode" {
  local spark_staging_dir=$(dirname ${SPARK_TMP_FILE})
  sc_update_to_spark_env "SPARK_EGO_STAGING_DIR" "${spark_staging_dir}"
  run $SPARK_HOME/bin/spark-submit --master spark://$SYM_MASTER_HOST:7077 \
				   --deploy-mode cluster \
                                   --class spark.autoTest.tool.SleepSparkPi \
                                   --conf "spark.ego.distribute.files=true" \
                                   $TEST_TOOL_HOME/lib/autoTestExamples.jar 1 30
  run "ls ${spark_staging_dir}"
  local spark_job_staging_dir=${output}
  sleep 40
  run "ls ${spark_staging_dir}/${spark_job_staging_dir}"
  
  assert_contains "${output}" "No such file or directory"
}

