`timescale 1ns / 1ps

module test_bench;

  reg           CLK;
  reg           RST_n;
  reg           Bit_in;
  reg     [2:0] op;
  wire    [6:0] Data_out;
  wire          Done;

  integer       total_tests;
  integer       passed_tests;
  integer       failed_tests;

  ALU dut (
      .CLK(CLK),
      .RST_n(RST_n),
      .Bit_in(Bit_in),
      .op(op),
      .Data_out(Data_out),
      .Done(Done)
  );

  // Reloj de 10 ns
  initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
  end

  // VCD para GTKWave
  initial begin
    $dumpfile("ALU_tb.vcd");
    $dumpvars(0, test_bench);
  end

  task initial_reset;
    begin
      RST_n  = 1'b0;
      Bit_in = 1'b0;
      op     = 3'b000;

      repeat (3) @(posedge CLK);

      // Liberamos reset despues del flanco activo.
      // Asi evitamos carreras y el primer bit se coloca en el siguiente negedge.
      #1;
      RST_n = 1'b1;
    end
  endtask

  task check_result;
    input [6:0] a;
    input [6:0] b;
    input [2:0] operation;
    input [6:0] expected;
    input [8*24:1] test_name;
    begin
      total_tests = total_tests + 1;

      if (Done !== 1'b1) begin
        failed_tests = failed_tests + 1;
        $display("[FAIL] %-24s | Done no se activo. Data_out=%0d (%b)", test_name, Data_out,
                 Data_out);
      end else if (Data_out !== expected) begin
        failed_tests = failed_tests + 1;
        $display("[FAIL] %-24s | A=%0d B=%0d op=%b | esperado=%0d (%b), obtenido=%0d (%b)",
                 test_name, a, b, operation, expected, expected, Data_out, Data_out);
      end else begin
        passed_tests = passed_tests + 1;
        $display("[PASS] %-24s | A=%0d B=%0d op=%b | resultado=%0d (%b)", test_name, a, b,
                 operation, Data_out, Data_out);
      end
    end
  endtask

  // Envia una operacion completa.
  // IMPORTANTE:
  // Bit_in y op se cambian en negedge para que esten estables
  // antes del posedge que captura cada bit.
  task run_test;
    input [6:0] a;
    input [6:0] b;
    input [2:0] operation;
    input [6:0] expected;
    input [8*24:1] test_name;

    integer i;
    begin
      // A[0]
      @(negedge CLK);
      op     = operation;
      Bit_in = a[0];
      @(posedge CLK);
      #1;

      // A[1] ... A[6]
      for (i = 1; i < 7; i = i + 1) begin
        @(negedge CLK);
        Bit_in = a[i];
        @(posedge CLK);
        #1;
      end

      // B[0] ... B[6]
      for (i = 0; i < 7; i = i + 1) begin
        @(negedge CLK);
        Bit_in = b[i];
        @(posedge CLK);
        #1;
      end

      // La ALU final calcula en el mismo flanco que captura B[6].
      check_result(a, b, operation, expected, test_name);
    end
  endtask

  initial begin
    total_tests  = 0;
    passed_tests = 0;
    failed_tests = 0;

    $display("====================================================");
    $display(" Testbench ALU serial 7 bits");
    $display(" Reset unico al inicio");
    $display(" Entradas aplicadas en negedge, capturadas en posedge");
    $display(" Done esperado en el flanco que captura el bit 14");
    $display("====================================================");

    initial_reset();

    run_test(7'd10, 7'd5, 3'b000, 7'd15, "SUMA 10+5");
    run_test(7'b1010101, 7'b1100110, 3'b001, 7'b1000100, "AND");
    run_test(7'b1010101, 7'b1100110, 3'b010, 7'b1110111, "OR");
    run_test(7'b1010101, 7'b1100110, 3'b011, 7'b0110011, "XOR");
    run_test(7'd25, 7'd10, 3'b100, 7'd15, "RESTA 25-10");

    // Casos borde de 7 bits: resultados modulo 128
    run_test(7'd127, 7'd1, 3'b000, 7'd0, "OVERFLOW SUMA");
    run_test(7'd0, 7'd1, 3'b100, 7'd127, "UNDERFLOW RESTA");
    run_test(7'd127, 7'd127, 3'b001, 7'd127, "AND MAX");
    run_test(7'd0, 7'd127, 3'b010, 7'd127, "OR CON CERO");
    run_test(7'd85, 7'd85, 3'b011, 7'd0, "XOR IGUALES");

    $display("====================================================");
    $display(" Total: %0d | PASS: %0d | FAIL: %0d", total_tests, passed_tests, failed_tests);
    $display(" Archivo VCD generado: ALU_tb.vcd");
    $display("====================================================");

    repeat (4) @(posedge CLK);
    $finish;
  end

endmodule
