#!/usr/bin/env bats

load $TEST_TOOL_HOME/test/helpers/assertions/all
load $TEST_TOOL_HOME/scenario/scenario_minimun_conf
load $TEST_TOOL_HOME/lib/workload.func

setup() {
  TMP_FILE="${TEST_TOOL_HOME}/test/tmp/case_spark_shell.out"
  touch $TMP_FILE
}

teardown() {
  [ -f $TMP_FILE ] && rm -f $TMP_FILE
}

@test "set spark.ego.executor.idle.timeout=10 via cmd line only effect for spark shell or pyspark command" {
  sc_update_to_spark_default "spark.ego.executor.idle.timeout" 10
  ca_spark_shell_run_sleep 1 3 sync >> $TMP_FILE 3>&1
  ca_find_keyword_timeout $TMP_FILE "onStageCompleted: stageId" 30
  start_time=$(grep 'onStageCompleted: stageId' ${TMP_FILE} | awk '{print $(NF-6)}')
  ca_find_keyword_timeout $TMP_FILE "EGODeployScheduler: Cleanup executor" 30
  end_time=$(grep 'EGODeployScheduler: Cleanup executor' ${TMP_FILE} | awk '{print $1}')
  val=$(( $end_time - $start_time ))
  [ $val -ge 10000 ] && [ $val -le 12000 ] || [ $status -eq 0 ]
}

@test "set spark.ego.executor.slots.max=10 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --deploy-mode client --class spark.test.parameter.parameterTest "spark.ego.executor.slots.max=10"
  assert_output_contains "key:spark.ego.executor.slots.max val=10"
}

@test "set spark.ego.priority=100 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --deploy-mode client --class spark.test.parameter.parameterTest "spark.ego.priority=100"
  assert_output_contains "key:spark.ego.priority val=100"
}

@test "set spark.ego.submit.file.replication=1 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --deploy-mode client --class spark.test.parameter.parameterTest "spark.ego.submit.file.replication=1"
  assert_output_contains "key:spark.ego.submit.file.replication val=1"
}

@test "set spark.ego.distribute.files=" {
  run $SPARK_HOME/bin/spark-submit --deploy-mode client --class spark.test.parameter.parameterTest "spark.ego.submit.file.replication=1"
  assert_output_contains "key:spark.ego.submit.file.replication val=1"
}