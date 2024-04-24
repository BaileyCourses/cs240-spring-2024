#!/usr/bin/env python3

import sys

def main ():
    name = "TRY"
    length = 20
    start = 0x100

    objFile = ObjectFile("out.bin", length, name, start)
    objFile._emitHeaderRecord(name, start, length)
    objFile._emitTextRecord(start, [65, 66, 67])
    objFile._emitEndRecord(start)

def error(*values):
    raise RuntimeError(" ".join([str(value) for value in values]))

class ObjectFile:

    def __init__(self, filename, length, name = "", startAddress = 0):
        self._outFile = open(filename, "wb")

    # Layer 2: emits object code records

    def _emitTextRecord(self, loc, text):

        # Emit a Text Record

        loc = loc & 0xfffff

        locASCII = intToBytes(loc, 3)
        sizeASCII = intToBytes(len(text), 1)

        self._write('T', locASCII, sizeASCII, text)

    def _emitHeaderRecord(self, name, start, length):

        # Emit a Header record

        name = (name + "      ")[:6]
        start &= 0xfffff
        length &= 0xfffff

        startASCII = intToBytes(start, 3)
        lenASCII = intToBytes(length, 3)

        self._write('H', name, startASCII, lenASCII)

    def _emitEndRecord(self, entryPoint):
        # Emit an End record

        entryPoint &= 0xfffff

        entryASCII = intToBytes(entryPoint, 3)
        self._write('E', entryASCII)

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
