module id_ex(input clk,
             input rst,
				 input [15:0]imm_ext,
				 input [31:0]pcplus4,
				 input [4:0]rs,
				 input [4:0]rt,
				 input[4:0]write_reg,
				 input alu_src,
				 input mem_to_reg,
				 input reg_write,
				 input mem_read,
				 input mem_write,
				 input branch,
				 input [31:0]data1,
				 input [31:0]data2,
				 input [1:0]alu_op,
				 input flush,
				 
				 output reg [15:0]imm_ext_out,
				 output reg[31:0]pcplus4_out,
				 output reg[4:0]rs_out,
				 output reg[4:0]rt_out,
				 output reg[4:0]write_reg_out,
				 output reg alu_src_out,
				 output reg mem_to_reg_out,
				 output reg reg_write_out,
				 output reg mem_read_out,
				 output reg mem_write_out,
				 output reg branch_out,
				 output reg [31:0]data1_out,
				 output reg [31:0]data2_out,
				 output reg [1:0]alu_op_out);
				 
				 
				 always@(posedge clk)begin
if(rst||flush)begin
imm_ext_out<=16'd0;
pcplus4_out<=32'd0;
rs_out<=5'd0;
rt_out<=5'd0;
write_reg_out<=5'd0;
alu_src_out<=1'd0;
reg_write_out<=1'd0;
mem_to_reg_out<=1'd0;
mem_read_out<=1'd0;
mem_write_out<=1'd0;
branch_out<=1'd0;
data1_out<=32'd0;
data2_out<=32'd0;
alu_op_out<=2'd0;
end else begin
imm_ext_out<=imm_ext;
pcplus4_out<=pcplus4;
rs_out<=rs;
rt_out<=rt;
write_reg_out<=write_reg;
alu_src_out<=alu_src;
reg_write_out<=reg_write;
mem_to_reg_out<=mem_to_reg;
mem_read_out<=mem_read;
mem_write_out<=mem_write;
branch_out<=branch;
data1_out<=data1;
data2_out<=data2;
alu_op_out<=alu_op;
end
end 
endmodule