#!/bin/bash

for u in $@; do
	echo "0" >/root/ge$u/value
done
