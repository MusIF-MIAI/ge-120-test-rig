#!/bin/bash

for u in $@; do
	echo "in" >/root/ge$u/direction
done
