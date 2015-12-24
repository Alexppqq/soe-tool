#!/usr/bin/env bats

load $TEST_TOOL_HOME/test/helpers/assertions/all
load $TEST_TOOL_HOME/scenario/scenario_minimum_conf
load $TEST_TOOL_HOME/lib/worklaod.func

setup() {
  sc_backup_spark_conf
}

teardown() {
  ca_recover_and_exit
}

@test "set spark.ego.executor.idle.timeout=10 via cmd line only effect for spark shell or pyspark command" {
  ca_update_to_spark_log4j "log4j.rootCategory" INFO
  ca_update_to_spark_log4j "log4j.appender.console.layout.ConversionPattern" "%r %d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n"
  sc_update_to_spark_default "spark.ego.executor.idle.timeout" 10
  ca_spark_shell_run_sleep 1 3 'sync' 2 >> $BATS_TMPDIR/$BATS_TEST_NAME.out
  start_time = $( cat $BATS_TMPDIR/$BATS_TEST_NAME.out | grep '' | awk '{print $1}')
  end_time = $(cat $BATS_TMPDIR/$BATS_TEST_NAME.out | grep '' | awk '{print $1}')
  val = $(expr $end_time - $start_time)
  [ $val -ge 10000 ] && [ $val -le 12000 ]
  [ $status -eq 0 ]
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