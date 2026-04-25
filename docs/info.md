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

1. Apply a reset (rst_n = 0) and then release it (rst_n = 1).
2. Select the desired operation using op[2:0]:
   - 000: Addition
   - 001: AND
   - 010: OR
   - 011: XOR
   - 100: Subtraction

3. Provide the input data serially on Bit_in:
   - First send 7 bits of operand A (LSB first)
   - Then send 7 bits of operand B (LSB first)
   - One bit per clock cycle

4. After the 14th clock cycle:
   - The result will appear on Data_out[6:0]
   - The Done signal will go high for one clock cycle

5. Repeat the process for additional operations.

## External hardware

No external hardware is required.

The design can be tested using:
- FPGA or ASIC simulation environment
- Logic analyzer
- Manual signal driving via GPIOs
