module mem_wb_scan(input clk,
              input rst,
				  input[31:0] alu_result,
				  input[31:0] dataread,
				  input mem_to_reg,
				  input reg_write,
				  input[4:0]des_reg,
				  
				  input scan_en,
				  input scan_in,
				  
				  output [31:0]alu_res_out,
				  output  [31:0]data_read_o,
				  output  mem_to_reg_o,
				  output  reg_write_o,
				  output  [4:0]des_reg_o,
				  
				  output scan_out);

				  wire [70:0]parallel_in;
				  wire [70:0]parallel_out;
				  assign parallel_in={alu_result,dataread,mem_to_reg,reg_write,des_reg};
            
				scan_reg #(.WIDTH(71)) uud(.clk(clk),
				                           .rst(rst),
													.scan_en(scan_en),
													.scan_in(scan_in),
													.funct_in(parallel_in),
													.load(1'b1),
													.flush(1'b0),
													.scan_out(scan_out),
													.parallel_out(parallel_out));
											
									assign des_reg_o=parallel_out[4:0];
							      assign reg_write_o=parallel_out[5];
							      assign mem_to_reg_o=parallel_out[6];
							      assign data_read_o=parallel_out[38:7];
							      assign alu_res_out=parallel_out[70:39];
									
				  endmodule