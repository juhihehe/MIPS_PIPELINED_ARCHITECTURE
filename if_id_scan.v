module if_id_scan(input clk,
                  input rst,
						input flush,
						input stall,
						input [31:0]instruction,
						input [31:0]pcplus4,
						input scan_en,
						input scan_in,
						output scan_out,
						output  [31:0]inst,
						output [31:0]pcstore);

		wire[63:0]parallel_in;
      wire[63:0]parallel_out;

assign parallel_in={pcplus4,instruction};	

assign inst = parallel_out[31:0];
assign pcstore= parallel_out[63:32];

scan_reg #(.WIDTH(64)) uud(.clk(clk),
             .rst(rst),
				 .scan_en(scan_en),
				 .scan_in(scan_in),
				 .funct_in(parallel_in),
				 .load(~stall),
				 .flush(flush),
				 .scan_out(scan_out),
				 .parallel_out(parallel_out));
				
				
						endmodule