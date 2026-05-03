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

endinterface : mmio_if