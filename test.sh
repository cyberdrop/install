#!/bin/bash

pass()
{
    printf '%-50s\033[32m%s\033[0m%s\n' "$1" "[PASS]"
}

fail()
{
    printf '%-50s\033[31m%s\033[0m%s\n' "$1" "[FAIL]"
}

fail "Testing a failure"
pass "Testing a pass"