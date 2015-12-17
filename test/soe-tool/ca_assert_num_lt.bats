#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
    export val_case_log_dir=$BATS_TMPDIR
    export val_case_name=$BATS_TEST_NAME
}

teardown() {
    [ -f $BATS_TMPDIR/caseResult ] && rm -rf $BATS_TMPDIR/caseResult
}

@test "assert_num_lt < result pass" {
    run ca_assert_num_lt 1 2 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Pass"
}

@test "assert_num_lt > failed" {
    run ca_assert_num_lt 1 0 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 2 "job not done"
}
