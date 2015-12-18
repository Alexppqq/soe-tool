#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
    export  MASTER_LOG=$BATS_TMPNAME
    export  Policy=""
    echo "Master application schedule policy fifo" > $BATS_TMPNAME
}

teardown() {
    rm -rf $BATS_TMPNAME
}

@test "get_policy_inuse sucessfully " {
    a=`grep -m1 "Master application schedule policy" $MASTER_LOG| awk -F " " '{print $NF}'`
    run echo $a
    assert_output_contains "fifo"
}


