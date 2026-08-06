module instructionmem(input [31:0]address,
                       output  [31:0]instruction);
reg [31:0] mem [0:63];
initial $readmemh("program_full.hex",mem);
assign instruction=mem[address[7:2]];							  


endmodule 