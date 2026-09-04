module id_ex_scan(input clk,
             input rst,
				 input [31:0]imm_ext,
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
				 
				 input scan_en,
				 input scan_in,
				 
				 
				 output  [31:0]imm_ext_out,
				 output [31:0]pcplus4_out,
				 output [4:0]rs_out,
				 output [4:0]rt_out,
				 output [4:0]write_reg_out,
				 output  alu_src_out,
				 output  mem_to_reg_out,
				 output  reg_write_out,
				 output  mem_read_out,
				 output  mem_write_out,
				 output  branch_out,
				 output  [31:0]data1_out,
				 output  [31:0]data2_out,
				 output  [1:0]alu_op_out,
				 
				 output scan_out);
				 
			
	    		wire[150:0]parallel_in;
				 wire[150:0]parallel_out;
				 assign parallel_in={imm_ext,pcplus4,rs,rt,write_reg,alu_src,mem_to_reg,reg_write,mem_read,mem_write,branch,data1,data2,alu_op};
			scan_reg #(.WIDTH(151)) register1 (.clk(clk),
			                                  .rst(rst),
														 .scan_en(scan_en),
														 .scan_in(scan_in),
														 .funct_in(parallel_in),
														 .load(~flush),
														 .flush(flush),
														 .scan_out(scan_out),
														 .parallel_out(parallel_out));	 

assign alu_op_out=parallel_out[1:0];
assign data2_out=parallel_out[33:2];
assign data1_out=parallel_out[65:34];
assign branch_out=parallel_out[66];
assign mem_write_out=parallel_out[67];
assign mem_read_out=parallel_out[68];
assign reg_write_out=parallel_out[69];
assign mem_to_reg_out=parallel_out[70];
assign alu_src_out=parallel_out[71];
assign write_reg_out=parallel_out[76:72];
assign rt_out=parallel_out[81:77];
assign rs_out=parallel_out[86:82];
assign pcplus4_out=parallel_out[118:87];
assign imm_ext_out=parallel_out[150:119];
endmodule