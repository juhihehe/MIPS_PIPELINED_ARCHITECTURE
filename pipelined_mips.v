module pipelined_mips(input clk,input rst,input scan_en,input scan_in,input fault_enable,input [4:0]fault_bit,input fault_value,output scan_out);

wire branch,zero,branch_sel,reg_dst,alu_src,mem_to_reg,reg_write,mem_read,mem_write,jump,mem_to_reg_o,reg_write_o,load_use_stall,zero1,jump_sel;
wire branch_out,alu_src_out,mem_to_reg_out,reg_write_out,mem_read_out,mem_write_out,mem_read2,mem_write2,mem_to_reg2,reg_write2;
wire[31:0]imm_ext_out,pcplus4_out,data1_out,data2_out,data_sent;
wire[31:0]pcplus4,branch_address,sign_extnd,pc_next,address,instruction,alu_inp_a,alu_inp_b,branch_data1,branch_data2;
wire[31:0]inst,pcstore,data1,data2,imm_ext,alu_in,alu_out,address_out,writedata_out,data_read,data_sel,alu_res_out,data_read_o,jump_address;
wire[1:0]alu_op,alu_op_out,forward_a,forward_b;
wire[4:0]rd,write_reg_out,write_reg2,des_reg_o,rs_out,rt_out;
wire[3:0]alu_ctrl;
wire branch_ex_stall,branch_mem_load_stall,stall;
wire if_id_scan_out,id_ex_scan_out,ex_mem_scan_out,mem_wb_scan_out;
reg [31:0]alu_faulted_out;


assign pcplus4=address+4;
assign branch_sel = branch & zero1 & ~stall;
assign branch_address = pcstore + (imm_ext << 2);
assign jump_address={pcstore[31:28],inst[25:0],2'b00};
assign jump_sel = jump & ~stall;
assign branch_data1 =
    (reg_write2 &&
     (write_reg2 != 5'd0) &&
     (write_reg2 == inst[25:21]))
        ? address_out
    :
    (reg_write_o &&
     (des_reg_o != 5'd0) &&
     (des_reg_o == inst[25:21]))
        ? data_sent
    :
        data1;

assign branch_data2 =
    (reg_write2 &&
     (write_reg2 != 5'd0) &&
     (write_reg2 == inst[20:16]))
        ? address_out
    :
    (reg_write_o &&
     (des_reg_o != 5'd0) &&
     (des_reg_o == inst[20:16]))
        ? data_sent
    :
        data2;
		  
		  
assign branch_ex_stall =
    branch &&
    reg_write_out &&
    (write_reg_out != 5'd0) &&
    (
        (write_reg_out == inst[25:21]) ||
        (write_reg_out == inst[20:16])
    );
	 
assign branch_mem_load_stall =
    branch &&
    mem_read2 &&
    (write_reg2 != 5'd0) &&
    (
        (write_reg2 == inst[25:21]) ||
        (write_reg2 == inst[20:16])
    );
	 
	 
assign stall =
    load_use_stall |
    branch_ex_stall |
    branch_mem_load_stall;
	 
	 
assign pc_next =
    branch_sel ? branch_address :
    jump_sel   ? jump_address   :
                 pcplus4;
					  
assign scan_out=mem_wb_scan_out;		

always@(*)begin
alu_faulted_out=alu_out;
if(fault_enable) 
alu_faulted_out[fault_bit]=fault_value;
end	  
pc pcsrc_pc(.clk(clk),
            .rst(rst),
				.stall(stall|scan_en),
				.pc_next(pc_next),
				.pc_out(address));
				
instructionmem instmem1(.address(address),
               .instruction(instruction));


if_id_scan if_id_uud(.clk(clk),
                     .rst(rst),
							.flush(branch_sel|jump_sel),
							.stall(stall),
							.instruction(instruction),
							.pcplus4(pcplus4),
							.scan_en(scan_en),
							.scan_in(scan_in),
							.scan_out(if_id_scan_out),
							.inst(inst),
							.pcstore(pcstore));
							
							
hazard_det hazard_det_uud(.id_ex_mem_read(mem_read_out),
                          .id_ex_write_reg(write_reg_out),
								  .if_id_rs(inst[25:21]),
								  .if_id_rt(inst[20:16]),
								  .stall(load_use_stall));
								  
ctrl_unit ctrl_unit_uud(.opcode(inst[31:26]),
                        .reg_dst(reg_dst),
								.alu_src(alu_src),
								.mem_to_reg(mem_to_reg),
								.reg_write(reg_write),
								.mem_read(mem_read),
								.mem_write(mem_write),
								.branch(branch),
								.jump(jump),
								.alu_op(alu_op));
				
mux #(.WIDTH(5)) regdst(.a(inst[20:16]),.b(inst[15:11]),.sel(reg_dst),.y(rd));					 

registerfile register(.clk(clk),
                      .reg_write(reg_write_o& ~scan_en),
							 .rs(inst[25:21]),
							 .rt(inst[20:16]),
							 .rd(des_reg_o),
							 .write_data(data_sent),
							 .data1(data1),
							 .data2(data2));
sign_extnd sign_extnd_m(.imm(inst[15:0]),
                        .imm_ext(imm_ext));
								
id_ex_scan idex1(.clk(clk),
      .rst(rst),
		.imm_ext(imm_ext),
		.pcplus4(pcstore),
		.rs(inst[25:21]),
		.rt(inst[20:16]),
		.write_reg(rd),
		.alu_src(alu_src),
		.mem_to_reg(mem_to_reg),
		.reg_write(reg_write),
		.mem_read(mem_read),
		.mem_write(mem_write),
		.branch(branch),
		.data1(data1),
		.data2(data2),
		.alu_op(alu_op),
		.flush(stall|branch_sel|jump_sel),
		.scan_en(scan_en),
		.scan_in(if_id_scan_out),
		
		.imm_ext_out(imm_ext_out),
		.pcplus4_out(pcplus4_out),
		.rs_out(rs_out),
		.rt_out(rt_out),
		.write_reg_out(write_reg_out),
		.alu_src_out(alu_src_out),
		.mem_to_reg_out(mem_to_reg_out),
		.reg_write_out(reg_write_out),
		.mem_read_out(mem_read_out),
		.mem_write_out(mem_write_out),
		.branch_out(branch_out),
		.data1_out(data1_out),
		.data2_out(data2_out),
		.alu_op_out(alu_op_out),
		.scan_out(id_ex_scan_out));		
	

forwarding frwd_uum(.id_ex_rs(rs_out),
                    .id_ex_rt(rt_out),
						  .ex_mem_write_reg(write_reg2),
						  .ex_mem_reg_write(reg_write2),
						  .mem_wb_write_reg(des_reg_o),
						  .mem_wb_reg_write(reg_write_o),
						  .forward_a(forward_a),
						  .forward_b(forward_b));

mux3 mux_a(.a(data1_out),.b(data_sent),.c(address_out),.sel(forward_a),.y(alu_inp_a));		

mux3 mux_b(.a(data2_out),.b(data_sent),.c(address_out),.sel(forward_b),.y(alu_inp_b));	


mux #(.WIDTH(32)) alu_src_mux (.a(alu_inp_b),.b(imm_ext_out),.sel(alu_src_out),.y(alu_in));	

compar compar_uum(.a(branch_data1),.b(branch_data2),.zero(zero1));
			  
alucontroller alu1(.ALU_Op(alu_op_out),.funct(imm_ext_out[5:0]),.alu_ctrl(alu_ctrl));

alu alu_uum(.a(alu_inp_a),
            .b(alu_in),
				.alu_ctrl(alu_ctrl),
				.c(alu_out),
				.zero(zero));
ex_mem_scan exmem(.clk(clk),
             .rst(rst),
				 .alu_result(alu_faulted_out),
				 .data2(alu_inp_b), 
				 .write_reg(write_reg_out),
				 .mem_read(mem_read_out),
				 .mem_write(mem_write_out),
				 .mem_to_reg(mem_to_reg_out),
				 .reg_write(reg_write_out),
				 
				 .scan_en(scan_en),
				 .scan_in(id_ex_scan_out),
				
				 
				 .address(address_out),
				 .writedata(writedata_out),
				 .write_reg_out(write_reg2),
				 .mem_read_out(mem_read2),
				 .mem_write_out(mem_write2),
				 .mem_to_reg_out(mem_to_reg2),
				 .reg_write_out(reg_write2),
				 
				 .scan_out(ex_mem_scan_out));

data_mem data_mem_uum(.clk(clk),
                
							 .mem_write(mem_write2 & ~scan_en),
							 .mem_read(mem_read2),
							 .address(address_out),
							 .write_data(writedata_out), 
							 .data_read(data_read));				 

mem_wb_scan mem_wb1(.clk(clk),
               .rst(rst),
					.alu_result(address_out),
					.dataread(data_read),
					.mem_to_reg(mem_to_reg2),
					.reg_write(reg_write2),
					.des_reg(write_reg2),
					
					.scan_en(scan_en),
					.scan_in(ex_mem_scan_out),
					
					.alu_res_out(alu_res_out),
					.data_read_o(data_read_o),
					.mem_to_reg_o(mem_to_reg_o),
					.reg_write_o(reg_write_o),
					.des_reg_o(des_reg_o),
					
					.scan_out(mem_wb_scan_out));


					
mux #(.WIDTH(32)) data_mem_mux(.a(alu_res_out),.b(data_read_o),.sel(mem_to_reg_o),.y(data_sent));

endmodule