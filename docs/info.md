<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This project implements a 7-bit Arithmetic Logic Unit (ALU) with serial input and parallel output.

The ALU supports the following operations:
- 000: Addition
- 001: AND
- 010: OR
- 011: XOR
- 100: Subtraction

Data is loaded serially through a single input (Bit_in) using a least significant bit (LSB) first protocol.

Each operation requires:
- 7 clock cycles to load operand A
- 7 clock cycles to load operand B
- Total: 14 clock cycles

After the 14th bit is received, the ALU immediately computes the result. The output is presented in parallel on Data_out[6:0], and the signal Done is asserted for one clock cycle to indicate that the result is valid.

After completing the operation, the ALU automatically resets its internal state and is ready to receive a new operation without requiring an external reset.


## How to test

asdf

## External hardware

asdf
