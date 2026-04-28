
`include "timescale.v"
`include "uart_defines.v"

 
module uart_wb (PCLK, PRESETn, 
	PWRITE, PSEL, PENABLE, PREADY, PADDR,
	wb_adr_int, PWDATA, PRDATA, PSLVERR, wb_dat8_i, wb_dat8_o, wb_dat32_o, PSTRB,
	we_o, re_o // Write and read enable output for the core
);

input 		  PCLK;

// WISHBONE interface	
input 		  PRESETn;
input 		  PWRITE;
input 		  PSEL;
input 		  PENABLE;
input [3:0]   PSTRB;
  input [`UART_ADDR_WIDTH-1:0] 	PADDR; //WISHBONE address line

`ifdef DATA_BUS_WIDTH_8
  input [7:0]  PWDATA; //input WISHBONE bus 
  output [7:0] PRDATA;
  reg [7:0] 	 PRDATA;
wire [7:0] 	 PWDATA;
reg [7:0] 	 wb_dat_is;
`else // for 32 data bus mode
input [31:0]  PWDATA; //input WISHBONE bus 
  output [31:0] PRDATA;
  reg [31:0] 	  PRDATA;
wire [31:0]   PWDATA;
reg [31:0] 	  wb_dat_is;
`endif // !`ifdef DATA_BUS_WIDTH_8

output [`UART_ADDR_WIDTH-1:0]	wb_adr_int; // internal signal for address bus
input [7:0]   wb_dat8_o; // internal 8 bit output to be put into wb_dat_o
output [7:0]  wb_dat8_i;
input [31:0]  wb_dat32_o; // 32 bit data output (for debug interface)
output 		  PREADY;
output        PSLVERR;
output 		  we_o;
output 		  re_o;

wire 			  we_o;
reg 			  PREADY;
reg [7:0] 	  wb_dat8_i;
wire [7:0] 	  wb_dat8_o;
wire [`UART_ADDR_WIDTH-1:0]	wb_adr_int; // internal signal for address bus
reg [`UART_ADDR_WIDTH-1:0]	wb_adr_is;
reg 								wb_we_is;
reg 								wb_cyc_is;
reg 								wb_stb_is;
reg [3:0] 						wb_sel_is;
wire [3:0]   PSTRB;
reg 			 wre ;// timing control signal for write or read enable
  
//-----------/////ERROR-LOGIC///------------
  
reg psel_prev;
always @(posedge PCLK or negedge PRESETn)
    if (!PRESETn)
        psel_prev <= 1'b0;
    else
        psel_prev <= PSEL;

wire penable_error = (PSEL & PENABLE) & (~psel_prev);

// ----------------------------------------------------------
// UART Errors — directly from wb_dat8_o
// wb_dat8_o is ASYNCHRONOUS in uart_regs.v (line 404)
// It immediately reflects LSR when wb_adr_is = 5'h05
// No sticky registers needed
// ----------------------------------------------------------

// LSR is on wb_dat8_o when wb_adr_is = UART_REG_LS = 5'h05
wire lsr_addressed = (wb_adr_is == 5'h05);

// Error 5 — Overrun Error (LSR[1])
// uart_rfifo.v → lsr1r → lsr → wb_dat8_o[1]
wire overrun_error = lsr_addressed & PRDATA[1];

// Error 6 — Parity Error (LSR[2])
// uart_receiver.v → lsr2r → lsr → wb_dat8_o[2]
wire parity_error  = lsr_addressed & PRDATA[2];

// Error 7 — Framing Error (LSR[3])
// uart_receiver.v → lsr3r → lsr → wb_dat8_o[3]
wire framing_error = lsr_addressed & PRDATA[3];

// Error 8 — Break Interrupt (LSR[4])
// uart_receiver.v → lsr4r → lsr → wb_dat8_o[4]
//wire break_error   = lsr_addressed & PRDATA[4];

// Error 9 — RX FIFO Error (LSR[7])
// any error in FIFO → lsr7r → lsr → wb_dat8_o[7]
//wire rx_fifo_error = lsr_addressed & PRDATA[7];

// ----------------------------------------------------------
// PSLVERR — All conditions combined
// ----------------------------------------------------------
assign PSLVERR = overrun_error     |   // LSR[1]
                 parity_error      |   // LSR[2]
                 framing_error     ;  // LSR[3]
  		       
  
  
  

// wb_ack_o FSM
reg [1:0] 	 wbstate;
  always  @(posedge PCLK or negedge PRESETn)
    if (!PRESETn) begin
		PREADY <= #1 1'b0;
		wbstate <= #1 0;
		wre <= #1 1'b1;
	end else
		case (wbstate)
			0: begin
				if (wb_stb_is & wb_cyc_is) begin
					wre <= #1 0;
					wbstate <= #1 1;
					PREADY <= #1 1;
				end else begin
					wre <= #1 1;
					PREADY <= #1 0;
				end
			end
			1: begin
			   PREADY <= #1 0;
				wbstate <= #1 2;
				wre <= #1 0;
			end
			2,3: begin
				PREADY <= #1 0;
				wbstate <= #1 0;
				wre <= #1 0;
			end
		endcase

assign we_o =  wb_we_is & wb_stb_is & wb_cyc_is & wre; //WE for registers	
assign re_o = ~wb_we_is & wb_stb_is & wb_cyc_is & wre ; //RE for registers	

// Sample input signals
  always  @(posedge PCLK or negedge PRESETn)
    if (!PRESETn) begin
		wb_adr_is <= #1 0;
		wb_we_is <= #1 0;
		wb_cyc_is <= #1 0;
		wb_stb_is <= #1 0;
		wb_dat_is <= #1 0;
		wb_sel_is <= #1 0;
	end else begin
		wb_adr_is <= #1 PADDR;
		wb_we_is <= #1 PWRITE;
		wb_cyc_is <= #1 PENABLE;
		wb_stb_is <= #1 PSEL;
		wb_dat_is <= #1 PWDATA;
		wb_sel_is <= #1 PSTRB;
	end

`ifdef DATA_BUS_WIDTH_8 // 8-bit data bus
  always @(posedge PCLK or negedge PRESETn)
    if (!PRESETn)
		PRDATA <= #1 0;
	else
		PRDATA <= #1 wb_dat8_o;

always @(wb_dat_is)
	wb_dat8_i = wb_dat_is;

assign wb_adr_int = wb_adr_is;

`else // 32-bit bus
// put output to the correct byte in 32 bits using select line
  always @(posedge PCLK or negedge PRESETn)
    if (!PRESETn)
		PRDATA <= #1 0;
	else if (re_o)
		case (wb_sel_is)
			4'b0001: PRDATA <= #1 {24'b0, wb_dat8_o};
			4'b0010: PRDATA <= #1 {16'b0, wb_dat8_o, 8'b0};
			4'b0100: PRDATA <= #1 {8'b0, wb_dat8_o, 16'b0};
			4'b1000: PRDATA <= #1 {wb_dat8_o, 24'b0};
			4'b1111: PRDATA <= #1 wb_dat32_o; // debug interface output
 			default: PRDATA <= #1 0;
		endcase // case(wb_sel_i)

reg [1:0] wb_adr_int_lsb;

always @(wb_sel_is or wb_dat_is)
begin
	case (wb_sel_is)
		4'b0001 : wb_dat8_i = wb_dat_is[7:0];
		4'b0010 : wb_dat8_i = wb_dat_is[15:8];
		4'b0100 : wb_dat8_i = wb_dat_is[23:16];
		4'b1000 : wb_dat8_i = wb_dat_is[31:24];
		default : wb_dat8_i = wb_dat_is[7:0];
	endcase // case(wb_sel_i)

  `ifdef LITLE_ENDIAN
	case (wb_sel_is)
		4'b0001 : wb_adr_int_lsb = 2'h0;
		4'b0010 : wb_adr_int_lsb = 2'h1;
		4'b0100 : wb_adr_int_lsb = 2'h2;
		4'b1000 : wb_adr_int_lsb = 2'h3;
		default : wb_adr_int_lsb = 2'h0;
	endcase // case(wb_sel_i)
  `else
	case (wb_sel_is)
		4'b0001 : wb_adr_int_lsb = 2'h3;
		4'b0010 : wb_adr_int_lsb = 2'h2;
		4'b0100 : wb_adr_int_lsb = 2'h1;
		4'b1000 : wb_adr_int_lsb = 2'h0;
		default : wb_adr_int_lsb = 2'h0;
	endcase // case(wb_sel_i)
  `endif
end

assign wb_adr_int = {wb_adr_is[`UART_ADDR_WIDTH-1:2], wb_adr_int_lsb};

`endif // !`ifdef DATA_BUS_WIDTH_8

endmodule










