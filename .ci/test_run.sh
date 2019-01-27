#!/bin/bash

echo "`date`"
echo "$TRAVIS_OS_NAME"
echo "========================================================================="
#if [ "$TRAVIS_OS_NAME" == "linux" ]; then
#fi
sk --help
echo "========================================================================="
oscdump 7778 &
pid=$!
sleep 1
echo "abc d"|sk
sleep 1
kill -9 $pid
echo "========================================================================="
echo "`date`"
echo "done"
