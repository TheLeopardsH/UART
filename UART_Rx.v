module UART_Rx(CLK,RST,SI,Rx_Byte, NINTI); 
input  CLK,RST, SI;
output reg [7:0] Rx_Byte;
output reg  NINTI; 

parameter IDLE = 3'b000;
parameter START_BIT = 3'b001; 
parameter RECV_BIT = 3'b010;
parameter STOP_BIT = 3'b011; 

parameter CLK_FREQ = 200000000;
parameter BAUD_RATE = 115200;

localparam CLKS_FOR_SEND = CLK_FREQ / BAUD_RATE;
localparam CLKS_FOR_RECV = CLKS_FOR_SEND / 2;

reg [2:0]state = 0; 
//reg [7:0]One_Byte = 0; // register for save data from input 
reg [2:0]Bit_Index = 0; 
reg [$clog2(CLKS_FOR_SEND)-1:0] tx_clk_count=0;


always @(posedge CLK)
 begin 
  if (RST) 
			begin 
			state <= IDLE;
			NINTI <= 1'b0;
			end
  else 
   begin 
	 case (state)
	  IDLE: // IDLE
	    begin
		   if (SI==1'b0) 
		   begin 
		   NINTI <= 1'b1;
		   state <= START_BIT; 
			end 
	     else 
		   begin 
			 NINTI <= 1'b1;
		    state <= IDLE; 
	      end	
	   end 
	  START_BIT: // REcieving the start bit ("0"), NINTI becomes low.  
	    begin 
		  NINTI <= 1'b0;		  
		  state <= RECV_BIT; 
		  Rx_Byte[Bit_Index] <= SI;
		  Bit_Index = Bit_Index + 1;
	    end 	
	  RECV_BIT: // Reception: Recieving 8 bits data
	    begin 
		  NINTI <= 1'b0;
		  Rx_Byte[Bit_Index] <= SI; // Bit_Index = (0 - 7) 000 to 111
		 
		  //sending 8 bits
		  if (Bit_Index < 7) 
		   begin
		    Bit_Index = Bit_Index + 1;
			 state <= RECV_BIT; 
	      end 	
		  else 
		   begin 
			 Bit_Index = 0; 
			 state <= STOP_BIT; 
			end 
		  
		 end 
	  STOP_BIT: // sending stop bit ("1") 
	   begin 
		 NINTI <= 1'b1; 
		 state <= IDLE; 
		end 
	
	 endcase
	end 
 end 
endmodule 

// SIDLE: sending IDLE, SO = 1; send = 1, move to S0
// S0, SO = 0, S1 -> S2 .....Sstop -> SIDLE (option 1)
// S0 (start bit) -> Strns (sending 8 bits) -> Sstop -> SIDLE (option 2) 
