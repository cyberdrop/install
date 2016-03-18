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
if id -u cyberdrop >/dev/null 2>&1; then
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



## Test 5: mongod user properly created
TEST_NAME="mongod User Exists"
if id -u cyberdrop >/dev/null 2>&1; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 6: checking /var/lib/mongo directory exists
TEST_NAME="/var/lib/mongo Directory Exists"
if -d "/var/lib/mongo"; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 7: checking /var/lib/mongo ownership is mongod:mongod
TEST_NAME="TODO"
fail $TEST_CNT "$TEST_NAME"



## Test 8: checking /var/log/mongodb/mongod.log file exists
TEST_NAME="/var/log/mongodb/mongod.log File Exists"
if -f "/var/log/mongodb/mongod.log"; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 9: checking /var/log/mongodb/mongod.log ownership is mongod:mongod
TEST_NAME="TODO"
fail $TEST_CNT "$TEST_NAME"



## Test 10: checking /etc/init.d/mongod file exists
TEST_NAME="/etc/init.d/mongod File Exists"
if -f "/etc/init.d/mongod"; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 11: checking /etc/mongod.conf file exists
TEST_NAME="/etc/mongod.conf File Exists"
if -f "/etc/mongod.conf"; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi



## Test 12: checking /etc/sysconfig/mongod file exists
TEST_NAME="/etc/sysconfig/mongod File Exists"
if -f "/etc/sysconfig/mongod"; then
	pass $TEST_CNT "$TEST_NAME"
else
	fail $TEST_CNT "$TEST_NAME"
fi