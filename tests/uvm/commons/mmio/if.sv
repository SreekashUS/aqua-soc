interface mmio_if 
#(
  parameter AW=8
  ,parameter DW=32
) 
(
  input logic clk
);

  logic [AW-1:0] addr;
  logic [DW-1:0] wdata;
  logic [DW-1:0] rdata;
  logic wr;

  logic valid;
  logic ready;

  logic nRst;

  modport driver 
  (
    output addr,wdata,wr,valid
    ,input rdata, ready
  );

  modport responder 
  (
    input addr,wdata,wr,valid
    ,output rdata,ready    
  );

  modport monitor
  (
    input addr,wdata,wr,valid,rdata,ready    
  );

endinterface :mmio_if