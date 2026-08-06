module data_mem(input clk,
               
					 input mem_write,
					 input mem_read,
					 input [31:0]address,
					 input [31:0]write_data,
					 output reg[31:0]data_read);
					 
reg [31:0]mem[0:63];
integer i;

initial begin
for(i=0;i<64;i=i+1)
 mem[i]=32'd0;
end


always@(*)begin
if(mem_read)begin
data_read=mem[address[7:2]];
end else begin
data_read=32'd0;
end
end


always@(posedge clk)begin
if(mem_write)
mem[address[7:2]]<=write_data;
end


endmodule 