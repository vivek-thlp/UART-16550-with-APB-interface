
/* ---------------------------- xtn [Transaction] ---------------------------------- */
class xtn extends uvm_sequence_item;
    `uvm_object_utils(xtn)  // factory registration

  // --> Members
  rand logic [7:0]  PWDATA;    // 1  8 --> data bus select
  rand logic [2:0] PADDR;   // 2
    rand logic             PWRITE;     // 3
  logic PRESETn,PENABLE,PSEL,PREADY,PSLVERR;
  logic [31:0]PRDATA;
  logic [3:0]PSTRB;
  
  
    

  // --> Internal Registers
    bit [7:0]IER;   // Interrupt Enable Register (IER)            1
    bit [7:0]IIR;   // Interrupt Identification Register (IIR)    2
    bit [7:0]FCR;   // FIFO Control Register (FCR)                3
    bit [7:0]LCR;   // Line Control Register (LCR)                4
    bit [7:0]LSR;   // Line Status Register (LSR)                 5
    bit [7:0]MCR;   // Modem Control Register (MCR)               6
    bit [7:0]MSR;   // Modem Status Register (MSR)                8
    bit [7:0]DL;    // Divisor Latches (DL)                       8
    bit [7:0]DL1;   // Divisor Latches (DL) [MSB]                 9
    bit [7:0]DL2;   // Divisor Latches (DL) [LSB]                 10
    bit [7:0]THR[$];// Transmittier Holding Register              11
    bit [7:0]RB[$]; // Readable Buffer                            12
  bit [31:0]wb_dat32_o;
  
  
  // --> Methods
    extern function new(string name = "xtn");
    extern function void do_print(uvm_printer printer);
endclass : xtn

/* ---------------------------- new ---------------------------------- */
function xtn::new(string name = "xtn");
    super.new(name);
endfunction : new

/* ---------------------------- do_print ---------------------------------- */
function void xtn::do_print(uvm_printer printer);
  super.do_print(printer);

  // --> printing transaction data
  printer.print_field("PRESETn",   this.PRESETn,   1, UVM_DEC);
  printer.print_field("PSEL",   this.PSEL,   1, UVM_DEC);
  printer.print_field("PREADY",   this.PREADY,   1, UVM_DEC);
  printer.print_field("PENABLE",   this.PENABLE,   1, UVM_DEC);
  printer.print_field("PWDATA",   this.PWDATA,   8, UVM_DEC);
  printer.print_field("PADDR",  this.PADDR,  3, UVM_DEC);
  printer.print_field("PWRITE",    this.PWRITE,    1, UVM_DEC);
  printer.print_field("PRDATA",   this.PRDATA,   8, UVM_DEC);
  printer.print_field("PSTRB",   this.PSTRB,   4, UVM_DEC);
  printer.print_field("PSLVERR",   this.PSLVERR,   1, UVM_DEC);
  printer.print_field("FRAME_ERROR",   this.LSR[3],   1, UVM_DEC);
  printer.print_field("OVERRUN_ERROR",   this.LSR[1],   1, UVM_DEC);
  printer.print_field("PARITY_ERROR",   this.LSR[2],   1, UVM_DEC);
  wb_dat32_o= {MSR,LCR,IIR,IER,LSR};



    foreach(THR[i])
      printer.print_field($sformatf("THR[%0d]",i),  this.THR[i],  8, UVM_DEC);

    foreach(RB[i])
      printer.print_field($sformatf("RB[%0d]",i),   this.RB[i],   8, UVM_DEC);

    printer.print_field("LCR",        this.LCR,        8, UVM_DEC);
    printer.print_field("MCR",        this.MCR,        8, UVM_DEC);
    printer.print_field("MSR",        this.MSR,        8, UVM_DEC);
    printer.print_field("LSR",        this.LSR,        8, UVM_BIN);
    printer.print_field("FCR",        this.FCR,        8, UVM_DEC);
    printer.print_field("IIR",        this.IIR,        8, UVM_DEC);
    printer.print_field("IER",        this.IER,        8, UVM_DEC);
    printer.print_field("DL1",        this.DL1,        8, UVM_DEC);
    printer.print_field("DL2",        this.DL2,        8, UVM_DEC);
  printer.print_field("wb_dat32_o",   this.wb_dat32_o, 32,UVM_BIN);

endfunction : do_print


          