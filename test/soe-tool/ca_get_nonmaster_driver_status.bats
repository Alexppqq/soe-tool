#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
	echo "Driver container state has changed to RUN" > $BATS_TMPNAME
}

teardown() {
	rm -rf $BATS_TMPNAME
}

@test "get_nonmaster_driver_status fail for null input" {
	run ca_get_nonmaster_driver_status
	assert_output_contains  'please specify a file'
}
@test "get_akka_driver_status sucessfully" {
        run ca_get_nonmaster_driver_status $BATS_TMPNAME
        assert_output_contains "RUN"
}

