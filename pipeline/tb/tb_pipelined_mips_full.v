`timescale 1ns/1ps

module tb_pipelined_mips_full;

    reg clk;
    reg rst;
	 reg [31:0]instruction_external;
	 reg [31:0]data_mem_external;
	 wire [31:0]address_external;
	 wire [31:0]data_address_external;
	 wire [31:0]data_mem_wrdata;
	 wire mem_read_external;
	 wire mem_write_external;

    pipelined_mips dut (
        .clk(clk),
        .rst(rst),
		  .instruction_external(instruction_external),
		  .address_external(addres_external),
		  .data_mem_external(data_mem_external),
		  .data_address_external(data_address_external),
		  .data_mem_wrdata(data_mem_wrdata),
		  .mem_read_external(mem_read_external),
		  .mem_write_external(mem_write_external)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        #12;
        rst = 1'b0;
    end

    initial begin
        $dumpfile("pipelined_mips.vcd");
        $dumpvars(0, tb_pipelined_mips_full);

        #500;
        $finish;
    end

    always @(negedge clk) begin
        if (!rst) begin
            $display(
                "Time=%0t PC=%h Instruction=%h Stall=%b Branch=%b",
                $time,
                dut.address,
                dut.instruction,
                dut.stall,
                dut.branch_sel
            );
        end
    end

endmodule