module mux3(input [31:0]a,b,c,
            input [1:0]sel,
				output reg [31:0]y);
				
always@(*)begin
if(sel==2'b00)begin
y=a;
end else if(sel==2'b01)begin
y=b;
end else begin
y=c;
end
end
endmodule