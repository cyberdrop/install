#!/bin/bash

TEST_CNT=0

pass()
{
	TEST_CNT=$((TEST_CNT+1))
    printf '%-75s\033[32m%s\033[0m%s\n' "[$1] $2" "[PASS]"
}

fail()
{
	TEST_CNT=$((TEST_CNT+1))
    printf '%-75s\033[31m%s\033[0m%s\n' "[$1] $2" "[FAIL]"
}


## Test 1: cyberdrop user properly created
TEST_NAME="cyberdrop User Exists"
if id -u "$1" >/dev/null 2>&1; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 2: git properly installed
TEST_NAME="git Installed"
if hash git 2>/dev/null; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 3: node properly installed
TEST_NAME="node Installed"
if hash node 2>/dev/null; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 4: mongod properly installed
TEST_NAME="mongod Installed"
if hash mongod 2>/dev/null; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi