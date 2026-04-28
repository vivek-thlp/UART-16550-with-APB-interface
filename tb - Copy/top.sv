`timescale 1ns/10ps

`include "uart_top.v"
`include "uart_if.sv"
`include "test_pkg.sv"
module top;
  import test_pkg::*;
  import uvm_pkg::*;

  bit PCLK,PCLK1;
  
  always #5 PCLK = !PCLK;
  always #10 PCLK1 = !PCLK1;

  wire a,b;

  uart_if in1(PCLK);
  uart_if in2(PCLK1);

  uart_top DUT1(.PCLK(PCLK),
                .PRESETn(in1.PRESETn),
                .PADDR(in1.PADDR),
                .PWDATA(in1.PWDATA),
                .PRDATA(in1.PRDATA),
                .PWRITE(in1.PWRITE),
                .PSEL(in1.PSEL),
                .PENABLE(in1.PENABLE),
                .PREADY(in1.PREADY),
                .PSLVERR(in1.PSLVERR),
                .PSTRB(in1.PSTRB),
                .int_o(in1.int_o),
                .stx_pad_o(a),
                .srx_pad_i(b),
                .rts_pad_o(in1.rts_pad_o),
                .cts_pad_i(in1.cts_pad_i),
                .dtr_pad_o(in1.dtr_pad_o),
                .dsr_pad_i(in1.dsr_pad_i),
                .ri_pad_i(in1.ri_pad_i),
                .dcd_pad_i(in1.dcd_pad_i),
                .baud_o(in1.baud_o));

  uart_top DUT2(.PCLK(PCLK1),
                .PRESETn(in2.PRESETn),
                .PADDR(in2.PADDR),
                .PWDATA(in2.PWDATA),
                .PRDATA(in2.PRDATA),
                .PWRITE(in2.PWRITE),
                .PSEL(in2.PSEL),
                .PENABLE(in2.PENABLE),
                .PREADY(in2.PREADY),
                .PSLVERR(in2.PSLVERR),
                .PSTRB(in2.PSTRB),
                .int_o(in2.int_o),
                .stx_pad_o(b),.srx_pad_i(a),
                .rts_pad_o(in2.rts_pad_o),
                .cts_pad_i(in2.cts_pad_i),
                .dtr_pad_o(in2.dtr_pad_o),
                .dsr_pad_i(in2.dsr_pad_i),
                .ri_pad_i(in2.ri_pad_i),
                .dcd_pad_i(in2.dcd_pad_i),
                .baud_o(in2.baud_o));

  initial
  begin
          uvm_config_db #(virtual uart_if)::set(null,"*","vif_0",in1);
          uvm_config_db #(virtual uart_if)::set(null,"*","vif_1",in2);

    run_test("orr_test");
   
  end
initial begin
  $dumpfile("wave.vcd");
  $dumpvars(0);
end

endmodule
