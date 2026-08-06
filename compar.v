module compar(input [31:0]a,b,
              output wire zero);
		
assign zero=(a==b)?1'b1:1'b0;
endmodule