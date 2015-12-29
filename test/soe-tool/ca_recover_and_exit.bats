#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
    export SPARK_CONF_DIR=$BATS_TMPDIR
    touch $SPARK_CONF_DIR/spark-env.sh.org.bak
    touch $SPARK_CONF_DIR/spark-defaults.conf.org.bak
    touch $SPARK_CONF_DIR/log4j.properties.org.bak
}

teardown() {
    rm -rf $SPARK_CONF_DIR/spark-env.sh.org.bak
    rm -rf $SPARK_CONF_DIR/spark-defaults.conf.org.bak
    rm -rf $SPARK_CONF_DIR/log4j.properties.org.bak
    rm -rf $SPARK_CONF_DIR/spark-env.sh
    rm -rf $SPARK_CONF_DIR/spark-defaults.conf
    rm -rf $SPARK_CONF_DIR/log4j.properties
}

@test "recover_and_exit can recover" {
	run ca_recover_and_exit 0
	[ -f $SPARK_CONF_DIR/spark-env.sh ] && [ -f $SPARK_CONF_DIR/spark-defaults.conf ] && [ -f $SPARK_CONF_DIR/log4j.properties ]
}

@test "recover_and_exit exit 0" {
        run ca_recover_and_exit 0
        test $status = 0
}

@test "recover_and_exit exit 1" {
        run ca_recover_and_exit 1
        test $status = 1
}

