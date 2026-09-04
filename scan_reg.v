module scan_reg #(parameter WIDTH =32)
               (input clk,
					input rst,
					input scan_en,
               input scan_in,
					input [WIDTH-1:0]funct_in,
				   input load,
			      input flush,
			      output scan_out,
					output reg [WIDTH-1:0]parallel_out
					);
					assign scan_out=parallel_out[WIDTH-1];
					always@(posedge clk or posedge rst)begin
					if(rst)begin
               parallel_out<={WIDTH{1'b0}};
					end else if(scan_en) begin
					parallel_out<={parallel_out[WIDTH-2:0],scan_in};
					end else if (flush)begin
					parallel_out<={WIDTH{1'b0}};
					end else if(load)begin
					parallel_out<=funct_in;
					end
					end
endmodule