#!/usr/bin/env bats
load ../helpers/assertions/all
load $BATS_CWD/lib/workload.func
load $BATS_CWD/lib/framework.func

setup() {
        echo "find the key word in files"  > $BATS_TMPNAME
}

teardown() {
        rm -rf $BATS_TMPNAME
}

@test "find key word fail for invalid input" {
        run ca_find_by_key_word   "sfaf"  ""
        assert_output_contains  'please specify file name and key word to look up'
}
@test "find key word sucessfully" {
        run ca_find_by_key_word $BATS_TMPNAME "key word"
        assert_output_contains  'key word'
}


