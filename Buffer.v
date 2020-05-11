module Buffer
  (
    input                 clk,
    input                 Reset,
    input                 load,
	 input  [7:0]           data_in,
    output reg [7:0]       data_out 
  );
 
  always @(posedge clk)
    if (Reset)
      data_out <= 0;
    else
	  if(load)
      data_out <= data_in;
    
endmodule
