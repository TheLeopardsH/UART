module main (Clock,Reset,load,SEND,READ,Tx_Data,NINTO,NINTI,Rx_Data);

input Clock,Reset,SEND,load,READ;
input [7:0] Tx_Data;
output [7:0] Rx_Data;
output NINTI,NINTO;

wire SO;
wire [7:0] data_out,R_Data;
Buffer TX_Buffer (Clock,Reset,load,Tx_Data,data_out);
USRT_Tx Transmission(Clock, Reset, SEND, data_out, SO, NINTO); 
USRT_Rx Reception(Clock,Reset,SO,R_Data, NINTI); 
Buffer Rx_Buffer (Clock,Reset,READ,R_Data,Rx_Data);

endmodule
