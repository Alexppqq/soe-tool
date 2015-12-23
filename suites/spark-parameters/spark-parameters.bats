#!/usr/bin/env bats

load $TEST_TOOL_HOME/test/helpers/assertions/all
load $TEST_TOOL_HOME/scenario/scenario_minimum_conf
load $TEST_TOOL_HOME/lib/worklaod.func

setup() {

}

teardown() {

}

@test "set spark.ego.executor.idle.timeout=300 via cmd line" {
  run $SPARK_HOME/bin/spark-submit --deploy-mode client --class spark.test.parameter.parameterTest "spark.ego.executor.idle.timeout=300"
  assert_output_contains "key:spark.ego.executor.idle.timeout val=300"

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