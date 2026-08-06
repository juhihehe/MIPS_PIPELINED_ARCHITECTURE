module hazard_det(input id_ex_mem_read,
                  input [4:0]id_ex_write_reg,
						input [4:0]if_id_rs,
						input [4:0]if_id_rt,
						
						output reg stall);
						
always@(*)begin
if(id_ex_mem_read&&(id_ex_write_reg==if_id_rs || id_ex_write_reg==if_id_rt))begin
stall=1;
end else begin
stall=0;
end
end						

endmodule