#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
        echo "\"submissionId\" : \"driver-20151217055757-0001-b9d7da07-7f2c-4789-8b64-6b03619df531\""  > $BATS_TMPNAME
}

teardown() {
        rm -rf $BATS_TMPNAME
}

@test "get_restapi_driver_name fail for null input" {
        run ca_get_restapi_driver_name
        test $status = 1  
        assert_output_contains  'please specify a file'
}
@test "get_restapi_driver_name sucessfully" {
        run ca_get_restapi_driver_name $BATS_TMPNAME
        test $status = 0
}


