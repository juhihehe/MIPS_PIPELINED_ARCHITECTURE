`timescale 1ns/1ps

module tb_pipelined_mips_full;

    reg clk;
    reg rst;

    pipelined_mips dut (
        .clk(clk),
        .rst(rst)
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