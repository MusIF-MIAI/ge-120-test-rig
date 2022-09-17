#!/bin/bash

for u in $@; do
	echo "out" >/root/ge$u/direction
done
