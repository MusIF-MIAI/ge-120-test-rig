#!/bin/bash

for u in $@; do
	if (test `cat /root/ge$u/value` -eq 1); then
		exit 1
	fi
done
