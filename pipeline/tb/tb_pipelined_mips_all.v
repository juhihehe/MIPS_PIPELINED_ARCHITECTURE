`timescale 1ns/1ps

module tb_pipelined_mips_all;

    reg clk;
    reg rst;

    reg [31:0] observed_reg [0:31];

    integer i;
    integer errors;
    integer stall_count;
    integer branch_taken_count;
    integer jump_taken_count;

    reg saw_negative_addi;
    reg saw_bad_s2_99;
    reg saw_bad_s5_88;
    reg saw_bad_t8_77;
    reg saw_bad_t8_88;

    pipelined_mips dut (
        .clk(clk),
        .rst(rst)
    );

    // 10 ns clock period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Asynchronous reset
    initial begin
        rst = 1'b1;
        #12;
        rst = 1'b0;
    end

    // Scoreboard and data-memory initialization
    initial begin
        errors = 0;
        stall_count = 0;
        branch_taken_count = 0;
        jump_taken_count = 0;

        saw_negative_addi = 1'b0;
        saw_bad_s2_99 = 1'b0;
        saw_bad_s5_88 = 1'b0;
        saw_bad_t8_77 = 1'b0;
        saw_bad_t8_88 = 1'b0;

        for (i = 0; i < 32; i = i + 1)
            observed_reg[i] = 32'hxxxxxxxx;

        // Let any memory initialization in the DUT complete first.
        #1;
        dut.data_mem_uum.mem[0] = 32'd77;
        dut.data_mem_uum.mem[1] = 32'd0;
        dut.data_mem_uum.mem[2] = 32'd0;
    end

    // Waveform dump
    initial begin
        $dumpfile("pipelined_mips_all.vcd");
        $dumpvars(0, tb_pipelined_mips_all);
    end

    // Monitor control flow and write-back activity.
    always @(negedge clk) begin
        if (!rst) begin
            $display(
                "Time=%0t PC=%h Instruction=%h Stall=%b BranchTaken=%b JumpTaken=%b",
                $time,
                dut.address,
                dut.instruction,
                dut.stall,
                dut.branch_sel,
                dut.jump_sel
            );

            if (dut.stall === 1'b1)
                stall_count = stall_count + 1;

            if (dut.branch_sel === 1'b1)
                branch_taken_count = branch_taken_count + 1;

            if (dut.jump_sel === 1'b1)
                jump_taken_count = jump_taken_count + 1;

            if ((dut.reg_write_o === 1'b1) &&
                (dut.des_reg_o != 5'd0)) begin

                observed_reg[dut.des_reg_o] = dut.data_sent;

                $display(
                    "    WB: Register[%0d] <= %0d (0x%h)",
                    dut.des_reg_o,
                    $signed(dut.data_sent),
                    dut.data_sent
                );

                // Confirm that addi sign extension produced -5.
                if ((dut.des_reg_o == 5'd23) &&
                    (dut.data_sent == 32'hfffffffb))
                    saw_negative_addi = 1'b1;

                // These writes belong to instructions that must be flushed.
                if ((dut.des_reg_o == 5'd18) &&
                    (dut.data_sent == 32'd99))
                    saw_bad_s2_99 = 1'b1;

                if ((dut.des_reg_o == 5'd21) &&
                    (dut.data_sent == 32'd88))
                    saw_bad_s5_88 = 1'b1;

                if ((dut.des_reg_o == 5'd24) &&
                    (dut.data_sent == 32'd77))
                    saw_bad_t8_77 = 1'b1;

                if ((dut.des_reg_o == 5'd24) &&
                    (dut.data_sent == 32'd88))
                    saw_bad_t8_88 = 1'b1;
            end
        end
    end

    task check_register;
        input [4:0] register_number;
        input [31:0] expected_value;
        begin
            if (observed_reg[register_number] !== expected_value) begin
                $display(
                    "FAIL: Register[%0d] = %h, expected %h",
                    register_number,
                    observed_reg[register_number],
                    expected_value
                );
                errors = errors + 1;
            end
            else begin
                $display(
                    "PASS: Register[%0d] = %0d (0x%h)",
                    register_number,
                    $signed(observed_reg[register_number]),
                    observed_reg[register_number]
                );
            end
        end
    endtask

    task check_integer;
        input integer actual;
        input integer expected;
        begin
            if (actual != expected) begin
                $display(
                    "FAIL: Count = %0d, expected %0d",
                    actual,
                    expected
                );
                errors = errors + 1;
            end
            else begin
                $display("PASS: Count = %0d", actual);
            end
        end
    endtask

    initial begin
        @(negedge rst);

        // Enough time for the complete program and pipeline drain.
        repeat (55) @(negedge clk);
        #1;

        $display("");
        $display("==================================================");
        $display("              FINAL REGISTER CHECKS");
        $display("==================================================");

        check_register(5'd8,  32'd10);          // t0: addi
        check_register(5'd9,  32'd20);          // t1: addi
        check_register(5'd10, 32'd30);          // t2: add
        check_register(5'd11, 32'd20);          // t3: sub
        check_register(5'd12, 32'd77);          // t4: lw
        check_register(5'd13, 32'd97);          // t5: lw -> add
        check_register(5'd14, 32'd30);          // t6: store/load readback
        check_register(5'd15, 32'd20);          // t7: and
        check_register(5'd16, 32'd30);          // s0: or
        check_register(5'd17, 32'd1);           // s1: signed slt
        check_register(5'd18, 32'd55);          // s2: branch flush
        check_register(5'd19, 32'd66);          // s3
        check_register(5'd20, 32'd30);          // s4: ALU -> branch
        check_register(5'd21, 32'd77);          // s5: load -> branch flush
        check_register(5'd22, 32'd77);          // s6: lw
        check_register(5'd23, 32'd42);          // s7: final store/load
        check_register(5'd24, 32'd44);          // t8: jump flush
        check_register(5'd25, 32'd123);         // t9: jump target
        check_register(5'd26, 32'd42);          // k0: store forwarding source

        $display("");
        $display("==================================================");
        $display("                DATA MEMORY CHECKS");
        $display("==================================================");

        if (dut.data_mem_uum.mem[1] !== 32'd30) begin
            $display(
                "FAIL: Memory[1] = %h, expected 0000001e",
                dut.data_mem_uum.mem[1]
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Memory[1] = 30");
        end

        if (dut.data_mem_uum.mem[2] !== 32'd42) begin
            $display(
                "FAIL: Memory[2] = %h, expected 0000002a",
                dut.data_mem_uum.mem[2]
            );
            errors = errors + 1;
        end
        else begin
            $display("PASS: Memory[2] = 42");
        end

        $display("");
        $display("==================================================");
        $display("             CONTROL/HAZARD CHECKS");
        $display("==================================================");

        $display("Expected total stall cycles: 4");
        check_integer(stall_count, 4);

        $display("Expected taken branches: 2");
        check_integer(branch_taken_count, 2);

        $display("Expected taken jumps: 1");
        check_integer(jump_taken_count, 1);

        if (saw_negative_addi !== 1'b1) begin
            $display("FAIL: Did not observe addi producing -5");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Observed addi sign extension producing -5");
        end

        if (saw_bad_s2_99 === 1'b1) begin
            $display("FAIL: Taken-branch wrong-path write s2=99 committed");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Taken branch flushed s2=99");
        end

        if (saw_bad_s5_88 === 1'b1) begin
            $display("FAIL: Load-dependent branch failed to flush s5=88");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Load-dependent taken branch flushed s5=88");
        end

        if ((saw_bad_t8_77 === 1'b1) ||
            (saw_bad_t8_88 === 1'b1)) begin
            $display("FAIL: Jump wrong-path instruction committed");
            errors = errors + 1;
        end
        else begin
            $display("PASS: Jump flushed/skipped both wrong-path writes");
        end

        $display("");
        $display("==================================================");

        if (errors == 0)
            $display("                  ALL TESTS PASSED");
        else
            $display("                  %0d TEST(S) FAILED", errors);

        $display("==================================================");

        $finish;
    end

    // Safety timeout
    initial begin
        #1000;
        $display("ERROR: Simulation timeout");
        $finish;
    end

endmodule
