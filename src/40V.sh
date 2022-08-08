#!/bin/bash
#set -x

FAULT=0

mount -o remount,rw /  &>/dev/null
mount -o remount,rw /boot &>/dev/null

./setup_pins.sh
ssh video3 mount -o remount,rw /  &>/dev/null
ssh video3 mount -o remount,rw /boot &>/dev/null
scp setup_pins.sh video3: &>/dev/null
scp pin*.sh video3: &>/dev/null

ssh video3 /root/setup_pins.sh &>/dev/null


##### TEST 1: 1N8 + NOT via 4N2 

echo TEST1

./pin_out.sh 1 2 3 4 5 6 7 9
ssh video3 ./pin_in.sh 16

echo "Test with all on"

./pin_set.sh 1 2 3 4 5 6 7 9

if (test `ssh root@video3 ./pin_get.sh 16` -ne 1); then
	echo test FAILED
	FAULT=1
fi


for k in 1 2 3 4 5 6 7 9; do
	echo "Test with $k off, others on"
	./pin_set.sh 1 2 3 4 5 6 7 9
	./pin_clear.sh $k
	if (test `ssh root@video3 ./pin_get.sh 16` -ne 0); then
		echo test FAILED
		FAULT=1
	fi
done


##### TEST 2: 1N8 + NOT via 4N2 

echo TEST2

ssh video3 ./pin_out.sh 1
ssh video3 ./pin_in.sh 15

./pin_out.sh 10 11 12 13 14 15 16

echo "Test with all on"

./pin_set.sh 10 11 12 13 14 15 16
ssh video3 ./pin_set.sh 1


if (test `ssh root@video3 ./pin_get.sh 15` -ne 1); then
	echo test FAILED
	FAULT=1
fi

echo Test OK

for k in 10 11 12 13 14 15 16; do
	echo "Test with $k off, others on"
	./pin_set.sh 10 11 12 13 14 15 16
	./pin_clear.sh $k
	if (test `ssh root@video3 ./pin_get.sh 15` -ne 0); then
		echo test FAILED
		FAULT=1
	fi
done
echo "Test with u32-1 off, others on"
./pin_set.sh 10 11 12 13 14 15 16
ssh video3 ./pin_clear.sh 1

if (test `ssh root@video3 ./pin_get.sh 15` -ne 0); then
	echo test FAILED
	FAULT=1
fi

echo Test OK


##### TEST 3: 1N8 + NOT via 4N2 

echo TEST3

ssh video3 ./pin_out.sh 13 12 11 10 9 7 6 5
ssh video3 ./pin_in.sh 14


echo "Test with all on"
ssh video3 ./pin_set.sh 13 12 11 10 9 7 6 5

if (test `ssh root@video3 ./pin_get.sh 14` -ne 1); then
	echo test FAILED
	FAULT=1
fi

echo Test OK


for k in 13 12 11 10 9 7 6 5; do
	echo "Test with u32-$k off, others on"
	ssh video3 ./pin_set.sh 13 12 11 10 9 7 6 5
	ssh video3 ./pin_clear.sh $k
	if (test `ssh root@video3 ./pin_get.sh 14` -ne 0); then
		echo test FAILED
		FAULT=1
	fi
done
echo test3 OK

ssh video3 ./pin_out.sh 3 2
ssh video3 ./pin_in.sh 4

echo "test all 1"
ssh video3 ./pin_set.sh 3 2
if (test `ssh root@video3 ./pin_get.sh 4` -ne 0); then
	echo test FAILED
	FAULT=1
fi

echo "test pin3 = 0"
ssh video3 ./pin_set.sh 3 2
ssh video3 ./pin_clear.sh 3
if (test `ssh root@video3 ./pin_get.sh 4` -ne 1); then
	echo test FAILED
	FAULT=1
fi

echo "test pin2 = 0"
ssh video3 ./pin_set.sh 3 2
ssh video3 ./pin_clear.sh 2
if (test `ssh root@video3 ./pin_get.sh 4` -ne 1); then
	echo test FAILED
	FAULT=1
fi

echo "test all = 0"
ssh video3 ./pin_clear.sh 2 3
if (test `ssh root@video3 ./pin_get.sh 4` -ne 1); then
	echo test FAILED
	FAULT=1
fi


./pin_in.sh 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16
ssh video3 ./pin_in.sh 1 2 3 4 5 6 7 9 10 11 12 13 14 15 16

if (test $FAULT -eq 0); then
	echo SUCCESS
else
	echo FAILURE
	exit 1
fi
