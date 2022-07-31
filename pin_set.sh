#!/bin/bash

for u in $@; do
	echo "1" >/root/ge$u/value
done
