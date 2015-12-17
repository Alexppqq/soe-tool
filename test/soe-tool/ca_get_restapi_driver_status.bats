#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/worklaod.func
load $BATS_CWD/lib/framework.func

setup() {
        echo ""success" : true"  > $BATS_TMPNAME
}

teardown() {
        rm -rf $BATS_TMPNAME
}

@test "get_restapi_driver_status fail for null input" {
        run ca_get_restapi_driver_status
        test $status = 1  
        assert_output_contains  'please specify a file'
}
@test "get_restapi_driver_status sucessfully" {
        run ca_get_restapi_driver_status $BATS_TMPNAME
        test $status = 0
}


