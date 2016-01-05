#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
	echo "16/01/04 22:35:18 INFO Client: Got allocation id=1076 from EGO..." > $BATS_TMPNAME
}

teardown() {
	rm -rf $BATS_TMPNAME
}

@test "get_nonmaster_driver_stderr fail for null input" {
	run ca_get_nonmaster_driver_stderr
	assert_output_contains  'please specify a file'
}
@test "get_akka_driver_stderr sucessfully" {
        run ca_get_nonmaster_driver_stderr $BATS_TMPNAME
        assert_output_contains "spark-driver-alloc-1076.stderr"
}

