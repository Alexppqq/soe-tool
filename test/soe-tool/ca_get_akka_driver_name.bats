#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
	echo "State of driver-20151217023811-0000-842124fe-0520-48f0-a9e1-778abf3715f8 is RUNNING" > $BATS_TMPNAME
}

teardown() {
	rm -rf $BATS_TMPNAME
}

@test "get_akka_driver_name fail for null input" {
	run ca_get_akka_driver_name 
	test $status = 1  
	assert_output_contains  'please specify a file'
}
@test "get_akka_driver_name sucessfully" {
        run ca_get_akka_driver_name  $BATS_TMPNAME
        test $status = 0
}

