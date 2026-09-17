`timescale 1ns/1ps

module DFT_test;
reg clk;
reg rst;
reg scan_en;
reg scan_in;
reg fault_enable;
reg [4:0]fault_bit;
reg fault_value;
integer i;
wire scan_out;
reg [31:0]fault_lessvalue;
reg [31:0]faulted_value;
reg fault_activated;
integer totalfaults;
integer detected_faults;
integer activated_faults;

pipelined_mips dut(.clk(clk),
                   .rst(rst),
						 .scan_en(scan_en),
						 .scan_in(scan_in),
						 .fault_enable(fault_enable),
						 .fault_bit(fault_bit),
						 .fault_value(fault_value),
						 .scan_out(scan_out));
						 
initial begin
clk=0;
forever begin
#5 clk=~clk;
end

end

task testing;
input [4:0]fault_bit_no;
input stuck_value;
begin

#1;
rst=1;
fault_enable=0;
fault_bit=fault_bit_no; //reseting the processor
fault_value=stuck_value;
#12;

rst=0;
wait(dut.write_reg_out==5'd10&&dut.alu_out==32'd30); //waiting for the processor to calculate alu value
$display("the alu out result at this stage is %0d",dut.alu_out);
fault_lessvalue=dut.alu_out;    //saving that alu value
fault_enable=1;
#1;
faulted_value=dut.alu_faulted_out;
if(fault_lessvalue!=dut.alu_faulted_out)begin
activated_faults=activated_faults+1;
$display("FAULT ACTIVATED");
fault_activated=1;
end else begin
$display("FAULT NOT ACTIVATED");
fault_activated=0;
end
$display("fault bit no %0d and stuck-at value is %0d",fault_bit_no,stuck_value);
$display("alu without stuck at fault output is %0d and alu out with fault is %0d ",fault_lessvalue,dut.alu_faulted_out);

@(posedge clk);
#1;
if(fault_activated==1&&faulted_value==dut.address_out)begin

$display("Fault propogated to ex/mem");
end else begin
$display("Fault not propogated to ex/mem");
end
fault_enable =0;

@(posedge clk);
#1;
if(fault_activated==1&&faulted_value==dut.data_sent)begin
detected_faults=detected_faults+1;
$display("Fault detected at mem/wb");
end else begin
$display("Fault not detected at mem/wb");
end

#1;
end

endtask
initial begin
rst=0;
scan_en=0;
scan_in=0;
fault_enable=0;
fault_bit=5'd0;
fault_value=0;
totalfaults=0;
detected_faults=0;
activated_faults=0;

for(i=0;i<32;i=i+1)begin
testing(i,1'b0);
testing(i,1'b1);
totalfaults=totalfaults+2;
end

$display("....................");
$display("TOTAL FAULTS = %0d",totalfaults);
$display("ACTIVATED FAULTS= %0d",activated_faults);
$display("DETECTED FAULTS = %0d",detected_faults);
$finish;
end

endmodule 