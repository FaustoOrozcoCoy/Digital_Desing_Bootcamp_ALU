`default_nettype none

module tt_um_ALU (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path, active high: 0=input, 1=output
    input  wire       ena,      // Goes high when the design is enabled
    input  wire       clk,      // Clock
    input  wire       rst_n     // Reset, active low
);

  wire [6:0] data_out;
  wire       done;

  ALU alu_inst (
      .CLK     (clk),
      .RST_n   (rst_n),
      .Bit_in  (ui_in[0]),
      .op      (ui_in[3:1]),
      .Data_out(data_out),
      .Done    (done)
  );

  // Salidas dedicadas
  assign uo_out[6:0] = data_out;
  assign uo_out[7] = done;

  // Pines bidireccionales no usados: configurados como entradas.
  // Aun cuando uio_oe=0, se asigna uio_out a 0 para no dejarlo flotante.
  assign uio_out = 8'b00000000;
  assign uio_oe = 8'b00000000;

  // Entradas no usadas conectadas a una reduccion para evitar warnings
  // de senales sin uso durante sintesis/lint.
  wire _unused = &{ena, ui_in[7:4], uio_in, 1'b0};

endmodule

`default_nettype wire

// Wrapper TinyTapeout para la ALU serial de 7 bits.
//
// Mapeo de pines:
//   ui_in[0]   -> Bit_in
//   ui_in[3:1] -> op[2:0]
//                 op = 000: suma
//                 op = 001: AND
//                 op = 010: OR
//                 op = 011: XOR
//                 op = 100: resta
//   ui_in[7:4] -> no usados
//
//   uo_out[6:0] -> Data_out[6:0]
//   uo_out[7]   -> Done
//
//   clk   -> CLK
//   rst_n -> RST_n, reset activo en bajo
//
// Los pines bidireccionales uio_* se dejan configurados como entradas
// para evitar salidas flotantes o sin asignar.
