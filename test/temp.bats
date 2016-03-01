#!/usr/bin/env bats

load test_helper
fixtures bats

@test "summary passing and skipping tests" {
  run filter_control_sequences bats -p $FIXTURE_ROOT/passing_and_skipping.bats
  [ $status -eq 0 ]
#  [ "${lines[2]}" == "2 tests, 0 failures, 1 skipped" ]
  [ "${lines[0]}" == "   a passing test1/2 ✓ a passing test" ]
  echo "${lines[@]}" > /tmp/gaogp 

}
