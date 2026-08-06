module ex_mem(input clk,
              input rst,
				  input[31:0]alu_result,
				  input [31:0]data2,
				  input [4:0]write_reg,
				  input mem_read,
				  input mem_write,
				  input mem_to_reg,
				  input reg_write,
				  
				  output reg[31:0]address,
				  output reg [31:0]writedata,
				  output reg[4:0]write_reg_out,
				  output reg mem_read_out,
				  output reg mem_write_out,
				  output reg mem_to_reg_out,
				  output reg reg_write_out);
				  
				 always@(posedge clk)begin
				 if(rst)begin
				 address<=32'd0;
				 writedata<=32'd0;
				 write_reg_out<=5'd0;
				 mem_read_out<=1'd0;
				 mem_write_out<=1'd0;
				 mem_to_reg_out<=1'd0;
				 reg_write_out<=1'd0;
				 end else begin
				 address<=alu_result;
				 writedata<=data2;
				 write_reg_out<=write_reg;
				 mem_read_out<=mem_read;
				 mem_write_out<=mem_write;
				 mem_to_reg_out<=mem_to_reg;
				 reg_write_out<=reg_write;
				 end
				end 
endmodule 