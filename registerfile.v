 module registerfile(input clk,
                   input reg_write,
                    input [4:0]rs,
						  input [4:0]rd,
						  input [4:0]rt,
						  input [31:0]write_data,
						  output reg [31:0]data1,
						  output reg [31:0]data2);
reg [31:0] regs [0:31];
integer i;

initial begin
for(i=0;i<32;i=i+1)
     regs[i]=32'b0;
end
always@(*)begin
 data1=regs[rs];
 data2=regs[rt];
end
always@(negedge clk)begin
if(reg_write && rd!=5'b0)begin
regs[rd]<=write_data;
end
end

endmodule