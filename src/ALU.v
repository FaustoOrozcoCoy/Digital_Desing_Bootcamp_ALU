`timescale 1ns / 1ps

// ALU serial de 7 bits
// Protocolo:
// - Reset activo en bajo: RST_n corresponde a /RST.
// - Al liberar reset, cada flanco positivo de CLK captura un bit valido.
// - Se reciben 14 bits en total:
//     * 7 bits del operando A, LSB primero.
//     * 7 bits del operando B, LSB primero.
// - En el flanco que captura el bit 14 se calcula el resultado,
//   Data_out queda en paralelo y Done se activa por un ciclo.
// - Luego la ALU queda lista para recibir una nueva operacion
//   desde el siguiente flanco de reloj.
//
// op:
// 000: suma
// 001: AND
// 010: OR
// 011: XOR
// 100: resta

module ALU (
    input  wire       CLK,
    input  wire       RST_n,
    input  wire       Bit_in,
    input  wire [2:0] op,
    output reg  [6:0] Data_out,
    output reg        Done
);

  reg [6:0] operand_a;
  reg [6:0] operand_b;
  reg [3:0] bit_count;

  always @(posedge CLK or negedge RST_n) begin
    if (!RST_n) begin
      operand_a <= 7'd0;
      operand_b <= 7'd0;
      bit_count <= 4'd0;
      Data_out  <= 7'd0;
      Done      <= 1'b0;
    end else begin
      // Done es un pulso de un ciclo cuando termina una operacion.
      Done <= 1'b0;

      if (bit_count < 4'd7) begin
        // Captura A[0] ... A[6]
        operand_a[bit_count] <= Bit_in;
        bit_count <= bit_count + 4'd1;

      end else if (bit_count < 4'd13) begin
        // Captura B[0] ... B[5]
        operand_b[bit_count-4'd7] <= Bit_in;
        bit_count <= bit_count + 4'd1;

      end else begin
        // bit_count == 13:
        // Captura B[6] y calcula usando el B completo:
        // {Bit_in, operand_b[5:0]}
        case (op)
          3'b000:  Data_out <= operand_a + {Bit_in, operand_b[5:0]};
          3'b001:  Data_out <= operand_a & {Bit_in, operand_b[5:0]};
          3'b010:  Data_out <= operand_a | {Bit_in, operand_b[5:0]};
          3'b011:  Data_out <= operand_a ^ {Bit_in, operand_b[5:0]};
          3'b100:  Data_out <= operand_a - {Bit_in, operand_b[5:0]};
          default: Data_out <= 7'd0;
        endcase

        Done <= 1'b1;

        // Preparar la siguiente operacion.
        operand_a <= 7'd0;
        operand_b <= 7'd0;
        bit_count <= 4'd0;
      end
    end
  end

endmodule
