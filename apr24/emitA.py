#!/usr/bin/env python3

import sys

def main ():
    name = "TRY"
    length = 10
    start = 0x100

    objFile = ObjectFile("out.bin", length, name, start)
    objFile._write("This is a string")
    objFile._write(48)
    objFile._write([48, 49, 50])


def error(*values):
    raise RuntimeError(" ".join([str(value) for value in values]))

class ObjectFile:

    def __init__(self, filename, length, name = "", startAddress = 0):
        self._outFile = open(filename, "wb")

    # Layer 1: Writes ints or strings to a file (layers on top of system write)

    def _write(self, *args):

        # If there are any lists in the arg list, expand them

        newargs = []
        for arg in args:
            if type(arg) == list:
                newargs += arg
            else:
                newargs.append(arg)
        args = newargs

        # For each arg, write it out

        for arg in args:

            if type(arg) == int:
                self._outFile.write(bytearray([arg]))

            elif type(arg) == str:
                self._outFile.write(bytearray(arg, "utf-8"))

            else:
                error("Unrecognized value: ", arg)

#
# intToBytes - convert an integer into a list of 8-bit integers
#

def intToBytes(value, size):
    bytes = []
    for _ in range(size):
        byte = value & 0xff
        bytes = [byte] + bytes
        value >>= 8
    return bytes

if __name__ == "__main__":
    main()
