#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
    export SPARK_CONF_DIR=$BATS_TMPDIR
    touch $SPARK_CONF_DIR/spark-defaults.conf
#    export envName=spark_log
#    export envValue=debug
}

teardown() {
    rm -rf $SPARK_CONF_DIR/spark-defaults.conf
}

@test "enable_shuffle_service add new line " {
    
    run ca_enable_shuffle_service
    run cat $SPARK_CONF_DIR/spark-defaults.conf
    assert_output_contains "spark.shuffle.service.enabled"
    
}

@test "enable_shuffle_service defaults is not empty add new line" {
    echo "safsdgadgasdfg" >> $SPARK_CONF_DIR/spark-defaults.conf
    run ca_enable_shuffle_service
    run cat $SPARK_CONF_DIR/spark-defaults.conf
    assert_output_contains "spark.shuffle.service.enabled"
}

@test "enable_shuffle_service has already set" {
    echo "spark.shuffle.service.enabled  false" >> $SPARK_CONF_DIR/spark-defaults.conf
    run ca_enable_shuffle_service
    run cat $SPARK_CONF_DIR/spark-defaults.conf
    assert_output_contains "true"
}

