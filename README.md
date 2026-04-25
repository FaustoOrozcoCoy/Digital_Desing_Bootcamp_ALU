![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/wokwi_test/badge.svg) ![](../../workflows/fpga/badge.svg)

# 7-bit Serial ALU – Tiny Tapeout Project

- [Project documentation](docs/info.md)

## 📘 Project Overview

This project was developed as part of a **Digital Design Bootcamp**, where the main challenge was to design and implement a **7-bit Arithmetic Logic Unit (ALU)** using a serial input interface and parallel output, targeting ASIC implementation with the **SkyWater 130nm PDK** and **TinyTapeout flow**.

According to the bootcamp specification :contentReference[oaicite:0]{index=0}, the ALU must:

- Support arithmetic and logic operations:
  - `000` → Addition  
  - `001` → AND  
  - `010` → OR  
  - `011` → XOR  
  - `100` → Subtraction  

- Receive input data **serially (LSB first)**  
- Output the result **in parallel**  
- Assert a **Done signal** when the operation is complete  

---

## ⚙️ How it works

The ALU operates using a serial input protocol:

1. When `rst_n = 0`, the system resets to its initial state.
2. When `rst_n = 1`, the ALU begins receiving data.
3. Data is provided through a single input (`Bit_in`) one bit per clock cycle:
   - First 7 bits → Operand A (LSB first)
   - Next 7 bits → Operand B (LSB first)
4. After receiving 14 bits, the ALU:
   - Executes the selected operation (`op[2:0]`)
   - Outputs the result in parallel (`Data_out[6:0]`)
   - Asserts `Done = 1` for one clock cycle
