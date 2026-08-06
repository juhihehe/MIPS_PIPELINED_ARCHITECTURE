module mips_top(input clk,rst);

wire [31:0]pc_out,instruction;
wire reg_dst,alu_src,mem_to_reg,reg_write,mem_read,mem_write,branch,jump,zero;
wire [1:0]alu_op;
wire[4:0]rd;
wire[31:0]data1,data2,imm_ext,alu_mux,address,data_read,write_data;
wire[3:0]alu_ctrl;
wire [31:0]pcplus4,branch_address,pc_beq,pc_next;
wire branch_ctrl;
wire[31:0]jump_add;


assign pcplus4=pc_out+4;
assign branch_address=pcplus4+(imm_ext<<2);
assign branch_ctrl=zero&branch;
assign jump_add={pcplus4[31:28],instruction[25:0],2'b00};


mux #(.WIDTH(32)) branch_mux(.a(pcplus4),
                             .b(branch_address),
									  .sel(branch_ctrl),
									  .y(pc_beq));
									  
mux #(.WIDTH(32)) jump_mux(.a(pc_beq),
                           .b(jump_add),
									.sel(jump),
									.y(pc_next));
pc u_pc(.clk(clk),

        .rst(rst),
		  .pc_next(pc_next),
		  .pc_out(pc_out));

instructionmem u_instructionmem(.address(pc_out),
                               .instruction(instruction));


										 
ctrl_unit u_ctrl_unit(.opcode(instruction[31:26]),
                      .reg_dst(reg_dst),
							 .alu_src(alu_src),
							 .mem_to_reg(mem_to_reg),
							 .reg_write(reg_write),
							 .mem_read(mem_read),
							 .mem_write(mem_write),
							 .branch(branch),
							 .jump(jump),
							 .alu_op(alu_op));
							 
							 
mux #(.WIDTH(5)) register_mux (.a(instruction[20:16]),
                               .b(instruction [15:11]),
										 .sel(reg_dst),
										 .y(rd));
													
registerfile u_registerfile(.clk(clk),
                            .rs(instruction[25:21]),
									 .rt(instruction[20:16]),
									 .rd(rd),
								    .reg_write(reg_write),
									 .write_data(write_data),
									 .data1(data1),
									 .data2(data2));

sign_extnd u_sign_extnd(.imm(instruction[15:0]),
                          .imm_ext(imm_ext));

mux #(.WIDTH(32)) alu_muxx (.a(data2),
                           .b(imm_ext),
							      .sel(alu_src),
							      .y(alu_mux));



alucontroller u_alucontroller(.ALU_Op(alu_op),
                              .funct(instruction[5:0]),
										.alu_ctrl(alu_ctrl));
											
alu u_alu(.a(data1),
          .b(alu_mux),
			 .alu_ctrl(alu_ctrl),
			 .c(address),
			 .zero(zero));




data_mem u_data_mem(.clk(clk),
                    .mem_write(mem_write),
						  .mem_read(mem_read),
						  .address(address),
						  .write_data(data2),
						  .data_read(data_read));
						  

mux  #(.WIDTH(32)) mem_to_reg_mux(.a(address),
                                  .b(data_read),
											 .sel(mem_to_reg),
											 .y(write_data));

endmodule 