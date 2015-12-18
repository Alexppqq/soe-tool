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


@test 'case_filter_notequal result pass' {
    run ca_case_filter_notequal "1" "2" "unmatch" 
    assert_contains "case filter was meeted"    
}

@test 'case_filter_notequal failed' {
    run ca_case_filter_notequal "abcd" "abcd" "unmatch"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Skip"
}

