module ex_mem_scan(input clk,
                   input rst,
						 input[31:0]alu_result,
				       input [31:0]data2,
				       input [4:0]write_reg,
				       input mem_read,
				       input mem_write,
				       input mem_to_reg,
				       input reg_write,
						 
						 input scan_en,
						 input scan_in,
				  
				       output [31:0]address,
				       output  [31:0]writedata,
				       output [4:0]write_reg_out,
				       output  mem_read_out,
				       output  mem_write_out,
				       output  mem_to_reg_out,
				       output  reg_write_out,
						 
						 output scan_out);

						 wire [72:0]parallel_in;
						 wire [72:0]parallel_out;
						 
						assign parallel_in={alu_result,data2,write_reg,mem_read,mem_write,mem_to_reg,reg_write};
						 scan_reg #(.WIDTH(73)) reg1(.clk(clk),
						                        .rst(rst),
														.scan_en(scan_en),
														.scan_in(scan_in),
														.funct_in(parallel_in),
														.load(1'b1),
														.flush(1'b0),
														.scan_out(scan_out),
														.parallel_out(parallel_out));
					    assign reg_write_out=parallel_out[0];
						 assign mem_to_reg_out=parallel_out[1];
						 assign mem_write_out=parallel_out[2];
						 assign mem_read_out=parallel_out[3];
						 assign write_reg_out=parallel_out[8:4];
						 assign writedata=parallel_out[40:9];
						 assign address=parallel_out[72:41];
						 endmodule