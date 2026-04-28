
/* ---------------------------- UART Interface ---------------------------------- */
interface uart_if(input bit PCLK);

    /* here
            i ------> input
            o ------> output
    */

/* ---------------------------- APB_uart Interface ---------------------------------- */
    logic                PRESETn;       // Asynchronous Reset
  logic [2:0]    PADDR;      // Used for register selection
  logic [3:0]     PSTRB;       // Select signal
  logic [7:0]     PWDATA;       // Data input
  logic [7:0]     PRDATA;       // Data output
    logic                PWRITE;        // Write or read cycle clection
    logic                PSEL;       // Specifies transfer cycle
    logic                PENABLE;       // A bus cycle is in progress
    logic                PREADY;       // Acknowledge of a transfer
    logic PSLVERR;

/* ---------------------------- other Interface ---------------------------------- */
    logic           int_o;          // Interrupt output
    logic           baud_o;         // baud rate output signal

/* ---------------------------- External (off-chip) connections Interface ---------------------------------- */
    logic           stx_pad_o;      // The serial output signal
    logic           srx_pad_i;      // The serial input signal
    logic           rts_pad_o;      // Request to Send
    logic           dtr_pad_o;      // Data Terminal Ready
    logic           cts_pad_i;      // Clear To Send
    logic           dsr_pad_i;      // Data To Ready
    logic           ri_pad_i;       // Ring Indicator
    logic           dcd_pad_i;      // Data Carrier Detect

/* ---------------------------- clocking blocks ---------------------------------- */
  clocking drv_cb @(posedge PCLK);   // driver clocking block
        default input #1 output #1;
        output PADDR;
        output PWDATA;
        output PWRITE;
        output PSTRB;
        output PRESETn;
        output PENABLE;
        output PSEL;
        input PREADY;
        input PSLVERR;
        input PRDATA;
        input int_o;
        input baud_o;
    endclocking : drv_cb

  clocking mon_cb @(posedge PCLK);   // monitor clocking block
        default input #1 output #1;
        input PADDR;
        input PWDATA;
        input PWRITE;
        input PSTRB;
        input PRESETn;
        input PENABLE;
        input PSEL;
        input PREADY;
        input PSLVERR;
        input PRDATA;
        input int_o;
        input baud_o;
    endclocking : mon_cb

/* ---------------------------- modport ---------------------------------- */
    modport MP_DR(clocking drv_cb);    // driver modport
    modport MP_MON(clocking mon_cb);    // moitor modport

endinterface : uart_if
