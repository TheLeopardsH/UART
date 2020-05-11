module UART_Tx(CLK, RST, Send, Data, SO, NINTO); 
input  CLK, RST, Send;
input [7:0]Data;
output reg SO, NINTO; // reg -> saving data 

parameter IDLE = 3'b000;
parameter START_BIT = 3'b001; 
parameter TRANS_BIT = 3'b010;
parameter STOP_BIT = 3'b011; 

parameter CLK_FREQ = 200000000;
parameter BAUD_RATE = 115200;

localparam CLKS_FOR_SEND = CLK_FREQ / BAUD_RATE;

reg [2:0]state = 0; 
reg [7:0]One_Byte = 0; // register for save data from input 
reg [2:0]Bit_Index = 0; 
reg [$clog2(CLKS_FOR_SEND)-1:0] tx_clk_count=0;

always @(posedge CLK)
 begin 
  if (RST) 
    begin 
	   state <= IDLE;
		SO <= 1'b1;
		NINTO <= 1'b0;
		tx_clk_count <= 0;
	 end
  else 
   begin 
	 case (state)
	  IDLE: // IDLE
	    begin 
		  SO <= 1'b1;
		  NINTO <= 1'b0;
		 
		 
		  if (Send) 
		   begin 
				One_Byte <= Data;
				state <= START_BIT; 
				end
	     else 
		   begin 
		    state <= IDLE; 
	      end	
	   end 
		
		
	  START_BIT: // Send out the start bit ("0"), NINTO becomes high.  
	    begin 
		  SO <= 1'b0;
		  NINTO <= 1'b1;	
	
	
		  //change for UART here
		  if(tx_clk_count < CLKS_FOR_SEND-1)
				begin
				tx_clk_count<=tx_clk_count+1;
				state <= START_BIT;
				end
			else
				begin
				tx_clk_count <=0;
				state <= TRANS_BIT; 
				end
	    end 	
		 
		 
	  TRANS_BIT: // Transmission: sending 8 bits data
	    begin 
		  NINTO <= 1'b1;
		  SO <= One_Byte[Bit_Index]; // Bit_Index = (0 - 7) 000 to 111
		 //change for UART here
		 if(tx_clk_count < CLKS_FOR_SEND -1)
				begin
				tx_clk_count<=tx_clk_count+1;
				state <= TRANS_BIT;
				end
		else
		begin
		tx_clk_count <=0;

		  //sending 8 bits
		  if (Bit_Index < 7) 
		   begin
		    Bit_Index = Bit_Index + 1;
			 state <= TRANS_BIT; 
	      end 	
		  else 
		   begin 
			 Bit_Index = 0; 
			 state <= STOP_BIT; 
			end 
		  end 
		 
		end
	  STOP_BIT: // sending stop bit ("1") 
	   begin 
		 SO <= 1'b1; 
		 NINTO <= 1'b1;
		if(tx_clk_count < CLKS_FOR_SEND -1)
				begin
				tx_clk_count<=tx_clk_count+1;
				state <= STOP_BIT;
				end
			else
				begin
				tx_clk_count <=0; 
				state <= IDLE; 
				end
		end 
	
	 endcase 
  end 
 end 
endmodule 
