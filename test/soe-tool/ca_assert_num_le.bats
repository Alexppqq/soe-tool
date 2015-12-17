#!/usr/bin/env bats
load ../helpers/assertions/all
source /root/gaop/soe-tool/lib/worklaod.func
source /root/gaop/soe-tool/lib/framework.func

setup() {
    export val_case_log_dir=$BATS_TMPDIR
    export val_case_name=$BATS_TEST_NAME
}

teardown() {
    [ -f $BATS_TMPDIR/caseResult ] && rm -rf $BATS_TMPDIR/caseResult
}

@test "assert_num_le < result pass" {
    run ca_assert_num_le 1 12 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Pass"
}

@test "assert_num_le = result pass" {
    run ca_assert_num_le 12 12 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Pass"
}

@test "assert_num_le > failed" {
    run ca_assert_num_le 12 2 "job not done"
    run cat $BATS_TMPDIR/caseResult
    assert_line 2 "job not done"
}