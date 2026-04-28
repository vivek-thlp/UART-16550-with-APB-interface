class mon extends uvm_monitor;
  `uvm_component_utils(mon)
  virtual uart_if.MP_MON vif;
  agt_config m_cfg;
  xtn xtn_h;

  uvm_analysis_port #(xtn) monitor_port;

  extern function new(string name = "mon", uvm_component parent);
  extern function void build_phase(uvm_phase phase);
  extern function void connect_phase(uvm_phase phase);
  extern task run_phase(uvm_phase phase);
  extern task collect_data();
endclass : mon

function mon::new(string name = "mon", uvm_component parent);
  super.new(name,parent);
  monitor_port = new("monitor_port",this);
endfunction : new

function void mon::build_phase(uvm_phase phase);
  if(!uvm_config_db #(agt_config)::get(this,"","agt_config",m_cfg))
    `uvm_fatal("CONFIG","cannot get() m_cfg from uvm_config_db. Have you set it?")

  super.build_phase(phase);
endfunction : build_phase

function void mon::connect_phase(uvm_phase phase);
  vif = m_cfg.vif;
endfunction : connect_phase

task mon::run_phase(uvm_phase phase);
  
  xtn_h = xtn::type_id::create("xtn_h");

  forever
    collect_data();
endtask : run_phase

task mon::collect_data();
  @(vif.mon_cb);
  wait(vif.mon_cb.PREADY)
    xtn_h.PWRITE = vif.mon_cb.PWRITE;
    xtn_h.PADDR = vif.mon_cb.PADDR;
    xtn_h.PWDATA = vif.mon_cb.PWDATA;
      xtn_h.PRESETn = vif.mon_cb.PRESETn;
      xtn_h.PENABLE = vif.mon_cb.PENABLE;
      xtn_h.PSEL = vif.mon_cb.PSEL;
      xtn_h.PRDATA = vif.mon_cb.PRDATA;
      xtn_h.PREADY = vif.mon_cb.PREADY;
      xtn_h.PSTRB = vif.mon_cb.PSTRB;
  	  xtn_h.PSLVERR=vif.mon_cb.PSLVERR;


  if(xtn_h.PADDR == 3 && xtn_h.PWRITE == 1)
        xtn_h.LCR = vif.mon_cb.PWDATA;

  if(xtn_h.PADDR == 2 && xtn_h.PWRITE == 1)
        xtn_h.FCR = vif.mon_cb.PWDATA;

    if(xtn_h.PADDR == 1 && xtn_h.PWRITE == 1 && xtn_h.LCR[7] == 0)
        xtn_h.IER = vif.mon_cb.PWDATA;

    //if(xtn_h.wb_addr_i == 4 && xtn_h.wb_we_i == 1)
      //  xtn_h.MSR = vif.mon_cb.wb_dat_i;

  if(xtn_h.PADDR == 0 && xtn_h.PWRITE == 1 && xtn_h.LCR[7] == 0)
        begin
          xtn_h.THR.push_back(vif.mon_cb.PWDATA);
          //$display("THR[0]");  
          //$display(xtn_h.THR[0]);
        end
        

    if(xtn_h.PADDR == 0 && xtn_h.PWRITE == 0 && xtn_h.LCR[7] == 0)
        begin
          xtn_h.RB.push_back(vif.mon_cb.PRDATA);
          //$display("RB[0]");  
          //$display(xtn_h.RB[0]);
        end

    if(xtn_h.PADDR == 2 && xtn_h.PWRITE == 0)
        begin
          wait(vif.mon_cb.int_o)
          @(vif.mon_cb);
          xtn_h.IIR = vif.mon_cb.PRDATA;
        end
    
  if(xtn_h.PADDR == 5 && xtn_h.PWRITE == 0)
        xtn_h.LSR = vif.mon_cb.PRDATA;
  	//	xtn_h.wb_dat8_o=vif.mon_cb.
    
    `uvm_info("mon", $sformatf("received data \n %s", xtn_h.sprint()), UVM_LOW)
  
  if(vif.mon_cb.PSLVERR)
    `uvm_info(get_type_name, "ERROR_DETECTED", UVM_LOW)
    
    monitor_port.write(xtn_h);    
endtask : collect_data