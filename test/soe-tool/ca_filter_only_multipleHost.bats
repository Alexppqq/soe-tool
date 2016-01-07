#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
    export global_case_log_dir=$BATS_TMPDIR
    export global_case_name=$BATS_TEST_NAME
}

teardown() {
    if  [ -f $BATS_TMPDIR/caseResult ]; then
        rm -rf $BATS_TMPDIR/caseResult
    else
        echo "null"
    fi
}


@test 'filter_only_multipleHost result pass' {
    export HOST_NUM=3
    run ca_filter_only_multipleHost 
    assert_output_contains "case filter was meeted"    
}

@test 'filter_only_multipleHost failed' {
    export HOST_NUM=1
    run ca_filter_only_multipleHost
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Skip"
}

