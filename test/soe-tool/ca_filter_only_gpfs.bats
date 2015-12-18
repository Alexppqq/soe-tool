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


@test 'filter_only_gpfs result pass' {
    export DIST_FILE_SYSTEM="GPFS"
    run ca_filter_only_gpfs 
    assert_output_contains "case filter was meeted"    
}

@test 'filter_only_gpfs failed' {
    export DIST_FILE_SYSTEM="XXXX"
    run ca_filter_only_gpfs
    run cat $BATS_TMPDIR/caseResult
    assert_line 1 "Skip"
}
