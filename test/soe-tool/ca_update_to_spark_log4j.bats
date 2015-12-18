#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
    export SPARK_CONF_DIR=$BATS_TMPDIR
    touch $SPARK_CONF_DIR/log4j.properties
#    export envName=spark_log
#    export envValue=debug
}

teardown() {
    rm -rf $SPARK_CONF_DIR/log4j.properties
}

@test "update_to_spark_log4j add new line " {
    
    run ca_update_to_spark_log4j spark_log debug
    run cat $SPARK_CONF_DIR/log4j.properties
    assert_output_contains "spark_log=debug"
    
}

@test "update_to_spark_log4j log4j is not empty add new line" {
    echo "hadoop_log=aaa" >> $SPARK_CONF_DIR/log4j.properties
    run ca_update_to_spark_log4j spark_log debug
    run cat $SPARK_CONF_DIR/log4j.properties
    assert_output_contains "spark_log=debug"      
}

@test "update_to_spark_log4j log4j has the target variable" {
    echo "spark_log=aaa" >> $SPARK_CONF_DIR/log4j.properties
    run ca_update_to_spark_log4j spark_log debug
    run cat $SPARK_CONF_DIR/log4j.properties
    assert_output_contains "spark_log=debug"
}

