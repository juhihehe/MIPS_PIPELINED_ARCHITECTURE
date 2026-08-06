module alucontroller(input [1:0]ALU_Op,
                      input [5:0]funct,
                       output reg[3:0]alu_ctrl);

always@(*)begin
case(ALU_Op)
           2'b00: alu_ctrl=4'b0010;// add for lw/sw
			  2'b01: alu_ctrl=4'b0110; // sub for lw/sw
			  2'b10: begin
			  case(funct)
			         6'b100000: alu_ctrl=4'b0010;//add
						6'b100010: alu_ctrl=4'b0110;//sub
						6'b100100: alu_ctrl=4'b0000;//and
						6'b100101: alu_ctrl=4'b0001;//or
						6'b101010: alu_ctrl=4'b0111;//slt
						6'b100111: alu_ctrl=4'b1100;//nor
						default: alu_ctrl=4'bx;
			  endcase
			  end
			  default:alu_ctrl=4'bx;
			  
endcase
end
endmodule 