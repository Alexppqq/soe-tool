#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
    export val_case_log_dir=$BATS_TMPDIR
    export val_case_name=$BATS_TEST_NAME
}

teardown() {
    if  [ -f $BATS_TMPDIR/caseResult ]; then
        rm -rf $BATS_TMPDIR/caseResult
    else
        echo "null"
    fi
}


@test 'filter_only_singleHost result pass' {
    export HOST_NUM=1
    run ca_filter_only_singleHost 
    assert_output_contains "case filter was meeted"    
}

@test 'filter_only_singleHost failed' {
    export HOST_NUM=12
    run ca_filter_only_singleHost
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Skip"
}
