#!/usr/bin/env python3

import sys

def main ():
    name = "TRY"
    length = 10
    start = 0x100

    objFile = ObjectFile("out.bin", length, name, start)
    objFile._emitTextBytes(start, "These are some bytes that could be code!")
    objFile.close(10)

def error(*values):
    raise RuntimeError(" ".join([str(value) for value in values]))

class ObjectFile:

    def __init__(self, filename, length, name = "", startAddress = 0):
        self._outFile = open(filename, "wb")
        self._byteBuffer = []
        self._bufferLoc = None
        self._maxLen = 5

        self._emitHeaderRecord(name, startAddress, length)

    # Layer 3: Handles of buffering of code bytes

    def close(self, entryPoint = 0):

        # Make sure to flush all of the buffered bytes first

        self._flushBuffer()

        self._emitEndRecord(entryPoint)

        self._outFile.close()
        self._outFile = None
        
    def _emitTextBytes(self, loc, byteList):

        # Buffers bytes up until a gap is found, or the text record is full

        if self._bufferLoc is None:

            # This is the first call to emitBytes

            self._bufferLoc = loc
        else:

            # Check for valid locations (must always follow current bytes)

            endLoc = self._bufferLoc + len(self._byteBuffer)

            if loc < endLoc:
                error("Error, location", loc,
                      "is less than end of current buffer location:", endLoc)

            # If the location skips over memory, first flush the buffer
            # using a short text record, then start over

            if loc > endLoc:
                self._flushBuffer()
                self._bufferLoc = loc
                
        # Add the bytes to the buffer

        self._byteBuffer += byteList

        # While we have too many bytes for a text record, emit a text record

        while len(self._byteBuffer) >= self._maxLen:

            # Emit the first block of bytes
            
            self._emitTextRecord(self._bufferLoc, self._byteBuffer[:self._maxLen])

            # Remove those bytes from the buffer

            self._byteBuffer = self._byteBuffer[self._maxLen:]

            # Update the buffer location accordingly

            self._bufferLoc += self._maxLen

    def _flushBuffer(self):

        # Flush all the bytes out

        if len(self._byteBuffer) > 0:

            # Emit the remaining block of bytes
            
            self._emitTextRecord(self._bufferLoc, self._byteBuffer[:self._maxLen])


        # Remove those bytes from the buffer

        self._byteBuffer = []

        # Update the buffer location accordingly

        self._bufferLoc = None

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
