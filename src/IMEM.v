module IMEM (
    input  [31:0] addr,
    output [31:0] Instruction
);
    reg [31:0] memory [0:255]; // 256 words * 4 bytes/word = 1KB instruction memory

    assign Instruction = (addr[11:2] < 128) ? memory[addr[11:2]] : 32'h00000063; // halt = beq x0, x0, 0

    initial begin
       
        if ($fopen("./mem/imem2.hex", "r"))
            $readmemh("./mem/imem2.hex", memory);
        else if ($fopen("./mem/imem.hex", "r"))
            $readmemh("./mem/imem.hex", memory);
        else
            $display("IMEM: No initial memory file found (imem2.hex or imem.hex).");
    end
endmodule