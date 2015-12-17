#!/usr/bin/env bats
load ../helpers/assertions/all
source /root/gaop/soe-tool/lib/worklaod.func
source /root/gaop/soe-tool/lib/framework.func

setup() {
        echo "find the key word in files"  > $BATS_TMPNAME
}

teardown() {
        rm -rf $BATS_TMPNAME
}

@test "find key word fail for invalid input" {
        run ca_find_by_key_word
        test $status = 1  
        assert_output_contains  'please specify key word and file to look up'
}
@test "find key word sucessfully" {
        run ca_find_by_key_word $BATS_TMPNAME "key word"
        test $status = 0
}


