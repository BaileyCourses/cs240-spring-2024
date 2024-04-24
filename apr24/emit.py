#!/usr/bin/env python3

import sys

def main ():
    name = "TRY"
    length = 10
    start = 0x100

    objFile = ObjectFile("out.bin", length, name, start)

#    objFile.emitSIC(10, 0x13, 1, 0x7bcd)
#    objFile.emitSIC(10, 0, 0, 0)
    objFile.emitSIC(10, 0, 0, 0xffff)
    objFile.emitType1(13, 0x13)
    objFile.emitType2(14, 0x13, 4, 6)
    objFile.emitType3(16, 0x13, 0, 0, 1, 0, 1, 0xabc)
#    objFile.emitType2(10, 0x22, 4, 6)
#    for loc in range(0x100, 0x100 + 10, 3):
#        objFile.emitSIC(loc, 0x4c, 1, 0xabc)

#    for loc in range(0x300, 0x300 + 70):
#        objFile.emitByte(loc, 0x4c)
        
#    objFile.emitSIC(20, 0x4c, 1, 0xabc)
#    objFile.emitType3(24, 0x4c, 1, 0, 1, 0, 1, 0xabc)
    objFile.emitType4(19, 0x4c, 1, 0, 1, 0, 1, 0xabc)
    objFile.close(10)

def error(*values):
    raise RuntimeError(" ".join([str(value) for value in values]))

class ObjectFile:

    def __init__(self, filename, length, name = "", startAddress = 0):
        self._outFile = open(filename, "wb")
        self._byteBuffer = []
        self._bufferLoc = None
        self._maxLen = 64

        self._emitHeaderRecord(name, startAddress, length)

    # Layer 4: supports instruction formats and data definitions

    def emitSIC(self, loc, opcode, X, addr):

        # Emit a SIC format instruction

	# Clear out any high bits in all provided values

        loc &= 0xfffff
        opcode &= 0x3f
        X &= 1
        addr &= 0x7fff

        # Create the bytes to emit

        bytes = [opcode << 2] + intToBytes(X << 15 | addr, 2)
        self._emitTextBytes(loc, bytes)

    def emitType1(self, loc, opcode):

        # Emit a SIC/XE type 1 instruction

	# Clear out any high bits in all provided values

        loc &= 0xfffff
        opcode &= 0x3f

        # Create the bytes to emit

        bytes = [opcode << 2]
        self._emitTextBytes(loc, bytes)

    def emitType2(self, loc, opcode, reg1, reg2):

        # Emit a SIC/XE type 2 instruction

	# Clear out any high bits in all provided values

        loc &= 0xfffff
        opcode &= 0x3f
        reg1 &= 0xf
        reg2 &= 0xf

        # Create the bytes to emit

        bytes = [opcode << 2, reg1 << 4 | reg2]
        self._emitTextBytes(loc, bytes)

    def emitType3(self, loc, opcode, N, I, X, B, P, disp):

        # Emit a SIC/XE type 3 instruction

	# Clear out any high bits in all provided values

        loc &= 0xfffff
        opcode &=0x3f
        N &= 1
        I &= 1
        X &= 1
        B &= 1
        P &= 1
        disp &= 0xfff

        # Create the bytes to emit

        bytes = [opcode << 2 | N << 1 | I] + intToBytes(X << 15 | B << 14
                                                        | P << 13 | disp, 2)
        self._emitTextBytes(loc, bytes)

    def emitType4(self, loc, opcode, N, I, X, B, P, addr):

        # Emit a SIC/XE type 4 instruction

        loc &= 0xfffff
        opcode = opcode & 0xfc
        N &= 1
        I &= 1
        X &= 1
        B &= 1
        P &= 1
        addr &= 0xfff

        # Create the bytes to emit

        bytes = [opcode | N << 1 | I] + intToBytes(X << 23 | B << 22 | P << 21
                                                   | 1 << 20 | addr, 3)
        self._emitTextBytes(loc, bytes)

    def emitByte(self, loc, byte):
        self._emitTextBytes(self, loc, [byte])

    def emitBytes(self, loc, bytes):
        self._emitTextBytes(self, loc, bytes)

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
