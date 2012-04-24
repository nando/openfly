#!/bin/bash
tail --bytes=+4 $1 > /tmp/bombout.tmp
mv /tmp/bombout.tmp $1
