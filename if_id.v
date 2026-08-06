module if_id(input clk,
             input rst,
				 input stall,
				 input flush,
				 input [31:0]instruction,
				 input [31:0]pcplus4,
				 output reg [31:0]inst,
				 output reg [31:0]pcstore);
				 
always@(posedge clk or posedge rst )begin
if(rst)begin
inst<=32'd0;
pcstore<=32'd0;
end else if (flush)begin
inst<=32'd0;
pcstore<=32'd0;
end else if(~stall) begin
inst<=instruction;
pcstore<=pcplus4;
end
end				 

endmodule 