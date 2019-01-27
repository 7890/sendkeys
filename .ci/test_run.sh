#!/bin/bash

echo "`date`"
echo "$TRAVIS_OS_NAME"
echo "========================================================================="
#if [ "$TRAVIS_OS_NAME" == "linux" ]; then
#fi
sk --help

#oscdump 7778 2>&1 > /tmp/out.txt &
#pid=$!
sleep 1
echo "abc d"|sk
sleep 1
#kill -9 $pid
#cat /tmp/out.txt
echo "========================================================================="
echo "`date`"
echo "done"
