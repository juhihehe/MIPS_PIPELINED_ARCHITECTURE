module mem_wb(input clk,
              input rst,
				  input[31:0] alu_result,
				  input[31:0] dataread,
				  input mem_to_reg,
				  input reg_write,
				  input[4:0]des_reg,
				  
				  output reg[31:0]alu_res_out,
				  output reg [31:0]data_read_o,
				  output reg mem_to_reg_o,
				  output reg reg_write_o,
				  output reg [4:0]des_reg_o);
				  
always@(posedge clk)begin
if(rst)begin
alu_res_out<=32'd0;
data_read_o<=32'd0;
mem_to_reg_o<=1'd0;
reg_write_o<=1'd0;
des_reg_o<=5'd0;

end else begin
alu_res_out<=alu_result;
data_read_o<=dataread;
mem_to_reg_o<=mem_to_reg;
reg_write_o<=reg_write;
des_reg_o<=des_reg;
end
end				  
endmodule