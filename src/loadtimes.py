#!/usr/bin/python2
import serial
import sys
import operator
import argparse

def myround(x, base=8, width=5):
    #hexnum = int(base * round(float(x)/base))
    hexnum = int(int(x)/8)
    return format(hexnum, "0"+str(width)+"x")

def convdac(V):
    hexnum = int(float(V)/(2.5)*4096-1)
    return format(hexnum, "03x")

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-f", help="config file to load", default = "trackersim.conf")
parser.add_argument("-u", help="ttyUSB device to connect to", default = "/dev/ttyUSB0")
parser.add_argument("--noconfig", help="do not load a config file (overrides -f)", action="store_true")
parser.add_argument("--script", help="run as script instead of shell", action="store_true")
args = parser.parse_args()

trackersim = serial.Serial(args.u, 115200)

configfile = open(args.f, "r")
lines = configfile.read().replace(" ","").split()

channeldata = {}
channelmemdata = {}
for i in range(16):
    i = hex(i)[-1]
    channeldata[i] = "00000"
    
dacdata = {"0" : "fff", "1" : "fff", "2" : "fff", "3" : "fff"}
auto = False
rapid = False
p = "p FFFFF"

if not args.noconfig:
    for i in range(16):
        i = hex(i)[-1]
        for line in lines:
            if line.lstrip()[0] == "#":
                continue
            line = line.lower()
            if line[0:2] == i + "=":
                channeldata[i] = myround(line[2:])
                break
        else:
            print "Warning: channel {} not set, initialized to 00000.".format(i)

    for line in lines:
        if line.lstrip()[0] == "#":
            continue
        line = line.lower()
        if line[:2] == "p=":
            print line
            p = "p " + myround(int(line[2:])*1000)
            print p
            break
    else:
        print "Warning: p not set, initialized to 1048.568 us."

    for i in range(4):
        i = str(i)
        j = "dac" + i
        for line in lines:
            if line.lstrip()[0] == "#":
                continue
            line = line.lower()
            if j in line:
                dacdata[i] = convdac(line[5:])
                break
        else:
            print "Warning: dac {} not set, initialized to 2.5.".format(i)

    for line in lines:
        if line.lstrip()[0] == "#":
            continue
        line = line.lower()
        if "auto=on" in line:
            auto = True
            break
        elif "auto=off" in line:
            auto = False
            break

sorted_ddata = sorted(dacdata.iteritems(), key=operator.itemgetter(0))
for i, j in sorted_ddata:
    mystr = "d " + i + j + "\r"
    print mystr
    trackersim.write(mystr)
    
sorted_cdata = sorted(channeldata.iteritems(), key=operator.itemgetter(0))
for i, j in sorted_cdata:
    mystr = "c " + i + " " + j + "\r"
    print mystr
    trackersim.write(mystr)

print p
trackersim.write(p)

if auto == True:
    trackersim.write("a" + "\r")  # not sure why this is neccesary, but it sometimes
    trackersim.write("a" + "\r")  # will not work without sending it twice
    print "auto = on"
elif auto == False:
    trackersim.write("z" + "\r")
    trackersim.write("z" + "\r")
    print "auto = off"

while not args.script:
    if auto:
        print "(cont on)",
    else:
        if rapid:
            print "(rapid on)"
        else:
            print "(cont off)"
    instr = raw_input("$ ").lower()
    if instr == "":
        pass
    elif instr == 'a':
        trackersim.write("a" + "\r")
        trackersim.write("a" + "\r")
        print "continuous mode on"
        auto = True
    elif instr == "z":
        trackersim.write("z" + "\r")
        trackersim.write("z" + "\r")
        print "continuous mode off"
        auto = False
    elif instr[0] == "d":
        trackersim.write(instr + "\r")
        dacdata[instr[2]] = instr[3:6]
    elif instr[0] == "c":
        if instr[4:] == "off":
            channelmemdata[instr[2]] = channeldata[instr[2]]
            channeldata[instr[2]] = myround(int(p[2:],16)*1000 + 40)
            trackersim.write("c " + instr[2] + " " + channeldata[instr[2]] + "\r")
            print "c " + instr[2] + " " + channeldata[instr[2]] + "\r"
            continue
        elif instr[4:] == "on":
            channeldata[instr[2]] = channelmemdata[instr[2]]
            trackersim.write("c " + instr[2] + " " + channeldata[instr[2]] + "\r")
            continue
        newhex = myround(instr[4:])
        trackersim.write("c " + instr[2] + " " + newhex + "\r")
        channeldata[instr[2]] = newhex
    elif instr == "s":
        trackersim.write("s" + "\r")
        rapid = False
    elif instr == "n":
        trackersim.write("n" + "\r")
        rapid = True
    elif instr == "m":
        trackersim.write("m" + "\r")
        rapid = False 
    elif instr[0] == "p":
        newhex = myround(int(instr[2:])*1000)
        p = "p " + newhex
        trackersim.write(p)
        # trackersim.write(instr)
        # p = instr
    elif instr == "l":
        sorted_ddata = sorted(dacdata.iteritems(), key=operator.itemgetter(0))
        for i, j in sorted_ddata:
            mystr = "d " + i + j + "\r"
            print mystr
        sorted_cdata = sorted(channeldata.iteritems(), key=operator.itemgetter(0))
        for i, j in sorted_cdata:
            mystr = "c " + i + " " + j + "\r"
            print mystr
        print p
    elif instr == "h":
        print "a\tconinuous mode on"
        print "z\tcontinuous mode off"
        print "s\tfire pulses once"
        print "n\trapid mode on"
        print "m\trapid mdoe off"
        print "d NXXX\tset dac N to XXX/FFF*2.5V"
        print "c N XXXXX set channel N start time to XXXXX (17 bits)"
        print "p XXXXX\tset period to XXXXX (17 bits) (8ns)"
        print "l\tprint all current values"
        print "h\tthis message"
        print "q\tquit"
    elif instr == 'q':
        print "thanks for playing"
        break
    else:
        print "invalid command"
