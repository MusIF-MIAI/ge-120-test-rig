#!/bin/bash

for u in $@; do
	if (test `cat /root/ge$u/value` -eq 0); then
		exit 1
	fi
done
