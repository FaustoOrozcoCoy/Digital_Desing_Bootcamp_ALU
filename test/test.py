# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, FallingEdge, RisingEdge


# Mapping used in tt_um_ALU.v:
# ui_in[0]   -> Bit_in
# ui_in[3:1] -> op[2:0]
# uo_out[6:0] -> Data_out[6:0]
# uo_out[7]   -> Done


def pack_ui(bit_in: int, op: int) -> int:
    """Build ui_in value from Bit_in and op."""
    return ((op & 0b111) << 1) | (bit_in & 0b1)


async def send_bit(dut, bit_value: int, op: int):
    """
    Drive Bit_in and op on the falling edge so they are stable
    before the ALU samples them on the next rising edge.
    """
    await FallingEdge(dut.clk)
    dut.ui_in.value = pack_ui(bit_value, op)
    await RisingEdge(dut.clk)


async def send_operand_lsb_first(dut, value: int, op: int):
    """Send a 7-bit value LSB first through ui_in[0]."""
    for i in range(7):
        await send_bit(dut, (value >> i) & 1, op)


async def run_alu_test(dut, a: int, b: int, op: int, expected: int, name: str):
    dut._log.info(f"Running {name}: A={a}, B={b}, op={op:03b}, expected={expected}")

    await send_operand_lsb_first(dut, a, op)
    await send_operand_lsb_first(dut, b, op)

    # The ALU asserts Done on the clock edge that captures the 14th bit.
    uo = int(dut.uo_out.value)
    data_out = uo & 0x7F
    done = (uo >> 7) & 0x1

    assert done == 1, (
        f"{name}: Done was not asserted. "
        f"uo_out={uo:08b}, Data_out={data_out:07b}"
    )

    assert data_out == (expected & 0x7F), (
        f"{name}: wrong result. "
        f"A={a}, B={b}, op={op:03b}, "
        f"expected={expected & 0x7F} ({expected & 0x7F:07b}), "
        f"got={data_out} ({data_out:07b})"
    )

    dut._log.info(f"PASS {name}: Data_out={data_out}, Done={done}")


@cocotb.test()
async def test_project(dut):
    dut._log.info("Start ALU TinyTapeout cocotb test")

    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0

    dut._log.info("Reset")
    await ClockCycles(dut.clk, 5)
    dut.rst_n.value = 1

    # Important:
    # Do not wait extra clock cycles after releasing reset.
    # This ALU has no enable/valid input, so every rising edge with rst_n=1
    # is interpreted as a valid serial input bit.

    await run_alu_test(dut, 10, 5, 0b000, 15, "ADD 10+5")
    await run_alu_test(dut, 0b1010101, 0b1100110, 0b001, 0b1000100, "AND")
    await run_alu_test(dut, 0b1010101, 0b1100110, 0b010, 0b1110111, "OR")
    await run_alu_test(dut, 0b1010101, 0b1100110, 0b011, 0b0110011, "XOR")
    await run_alu_test(dut, 25, 10, 0b100, 15, "SUB 25-10")

    await run_alu_test(dut, 127, 1, 0b000, 0, "ADD overflow")
    await run_alu_test(dut, 0, 1, 0b100, 127, "SUB underflow")
    await run_alu_test(dut, 127, 127, 0b001, 127, "AND max")
    await run_alu_test(dut, 0, 127, 0b010, 127, "OR with zero")
    await run_alu_test(dut, 85, 85, 0b011, 0, "XOR equal")

    dut._log.info("All ALU tests passed")
