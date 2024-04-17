#!/usr/bin/env python3

lineNo = 0
lineText = ""

def error(*args):

    """
    error - takes an number of parameters that are concatinated converted
               to strings and concatinated together.
    """

    # Create the template for the error message

    template = """Oh, my. An error has occurred
    %s
    Line %d: %s"""

    # Concatinate all arguments together

    errorMsg = " ".join([str(arg) for arg in args])

    # Fill in the template with the specific values of this error

    output = template % (errorMsg, lineNo, lineText)

    # Raise the error and exit

    raise SystemExit(output)

def main():
    global lineNo
    global lineText
    lineNo = 1
    lineText = "        lda     value"

    filename = "bob.asm"
    error("File not found:", filename)


if __name__ == "__main__":
    main()
