#!/usr/bin/python3
import sys
import os

FAILURE = False
FAIL_LINE = []
pincfg = []

PRE_CONF= [
        "mount -o remount,rw /  &>/dev/null"          ,
        " mount -o remount,rw /boot &>/dev/null     " ,
        "./setup_pins.sh                            " ,
        "ssh video3 mount -o remount,rw /  &>/dev/null",
        "ssh video3 mount -o remount,rw /boot &>/dev/null",
        "scp setup_pins.sh video3: &>/dev/null      " ,
        "scp pin*.sh video3: &>/dev/null            " ,
        "ssh video3 /root/setup_pins.sh &>/dev/null " ,
        "echo DONE PRE_conf"
        ]


# remote -- pin nr
PINS = [
    (True, '16'),
    (True, '15'),
    (True, '14'),
    (True, '13'),
    (True, '12'),
    (True, '11'),
    (True, '10'),
    (True, '9'),
    (True, '7'),
    (True, '6'),
    (True, '5'),
    (True, '4'),
    (True, '3'),
    (True, '2'),
    (True, '1'),
    (False, '16'),
    (False, '15'),
    (False, '14'),
    (False, '13'),
    (False, '12'),
    (False, '11'),
    (False, '10'),
    (False, '9'),
    (False, '7'),
    (False, '6'),
    (False, '5'),
    (False, '4'),
    (False, '3'),
    (False, '2'),
    (False, '1'),
]


def setup_io(line):
    global FAILURE
    global FAIL_LINE
    print("io", line)
    for i, bit_s in enumerate(line):
        if bit_s == '0':
            bit = 0
        elif bit_s == '1':
            bit = 1
        else:
            return

        remote, pin = PINS[i]
        pincfg.append((pin, bit, remote))

        command = ""

        if remote:
            command = "ssh video3 "

        if bit:
            command += "./pin_in.sh "
        else:
            command += "./pin_out.sh "

        command += pin

        if (os.system(command)) != 0:
            print(command + " SETUP FAILED!")
            FAILURE=True



def run_test(line):
    global FAILURE
    global FAIL_LINE
    print("test", line)
    for i, val in enumerate(line):
        pin, direction, remote = pincfg[i]
        if not direction:
            command = ""
            #output
            if remote:
                command += 'ssh video3 '
            if val == '1':
                command += './pin_set.sh '
            else:
                command += './pin_clear.sh '
            command += pin
            if (os.system(command)) != 0:
                print(command + " FAILED!")
                FAILURE=True

    for i, val in enumerate(line):
        pin, direction, remote = pincfg[i]
        if direction:
            command = ""
            #output
            if remote:
                command += 'ssh video3 '
            if val == '1':
                command += './pin_get_1.sh '
            else:
                command += './pin_get_0.sh '
            command += pin

            print(command, end='')

            if (os.system(command)) != 0:
                print(" FAILED!")
                FAILURE=True
                FAIL_LINE.append(i)
            else:
                print(" OK")
            


def test(conf_text):
    io_defs = None

    for line in conf_text.splitlines():
        try:
            if line[0] in ('0', '1'):
                if io_defs is None:
                    io_defs = line
                    setup_io(line)
                else:
                    run_test(line)
        except Exception as e:
            pass
        

if __name__ == '__main__':
    try: 
        filename = sys.argv[1]
        conf_text = open(filename, 'r').read()
    except Exception as e:
        print("cannot open conf file")
        sys.exit(1)
    for cmd in PRE_CONF:
        os.system(cmd)

    test(conf_text)

    print()
    print()
    if (FAILURE):
        os.system("/usr/games/cowsay -e xx Test FAILED")
        print("line(s) with failure: " + str(FAIL_LINE))
    else:
        os.system("figlet Test SUCCESSFUL")

