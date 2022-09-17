#!/bin/bash

for i in 2 3 4 14 15 17 18 27 22 23 24 10 9 25 11; do echo $i > /sys/class/gpio/export 2>/dev/null; done


ln -sf /sys/class/gpio/gpio2 /root/ge1    &>/dev/null
ln -sf /sys/class/gpio/gpio3 /root/ge2    &>/dev/null
ln -sf /sys/class/gpio/gpio4 /root/ge3    &>/dev/null
ln -sf /sys/class/gpio/gpio14 /root/ge4   &>/dev/null
ln -sf /sys/class/gpio/gpio15 /root/ge5   &>/dev/null
ln -sf /sys/class/gpio/gpio17 /root/ge6   &>/dev/null
ln -sf /sys/class/gpio/gpio18 /root/ge7   &>/dev/null
                                          &>/dev/null
ln -sf /sys/class/gpio/gpio27 /root/ge9   &>/dev/null
ln -sf /sys/class/gpio/gpio22 /root/ge10  &>/dev/null
ln -sf /sys/class/gpio/gpio23 /root/ge11  &>/dev/null
ln -sf /sys/class/gpio/gpio24 /root/ge12  &>/dev/null
ln -sf /sys/class/gpio/gpio10 /root/ge13  &>/dev/null
ln -sf /sys/class/gpio/gpio9  /root/ge14  &>/dev/null
ln -sf /sys/class/gpio/gpio25 /root/ge15  &>/dev/null
ln -sf /sys/class/gpio/gpio11 /root/ge16  &>/dev/null
