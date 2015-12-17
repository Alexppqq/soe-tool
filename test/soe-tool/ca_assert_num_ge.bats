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

@test "assert_num_ge > result pass" {
    run ca_assert_num_ge 2 1 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Pass"
}

@test "assert_num_ge = result pass" {
    run ca_assert_num_ge 2 2 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Pass"
}

@test "assert_num_ge < failed" {
    run ca_assert_num_ge 1 2 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 2 "job not done"
}
