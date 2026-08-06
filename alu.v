module alu(input [31:0]a,
           input [31:0]b,
			  input [3:0]alu_ctrl,
			  output reg[31:0]c,
			  output zero);
always@(*)begin
case(alu_ctrl)
        4'b0000:c=a&b;
		  4'b0001:c=a|b;
		  4'b0010:c=a+b;
		  4'b0110:c=a-b;
		  4'b0111:c=(a<b)?32'd1:32'd0;
		  4'b1100:c=~(a|b);
		  default:c=32'bx;
endcase
end
assign zero=(c==32'd0)?1:0;
			 
			
		
endmodule
	