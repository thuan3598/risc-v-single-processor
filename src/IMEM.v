module IMEM (
    input  [31:0] addr,
    output [31:0] Instruction
);
    reg [31:0] memory [0:255]; // 256 words * 4 bytes/word = 1KB instruction memory

    // Instruction fetch logic: return instruction or halt if out of bounds
    // addr[11:2] maps 32-bit byte address to word address (divide by 4)
    // The original logic checks for addr[11:2] < 128 (for SC1).
    // For a 256-word memory, the valid range is 0 to 255.
    // Let's keep the original SC1 behavior if that's the intent.
    assign Instruction = (addr[11:2] < 128) ? memory[addr[11:2]] : 32'h00000063; // halt = beq x0, x0, 0

    // Initial memory loading from hex file (kept as requested)
    initial begin
        // Try loading from imem2.hex first, then imem.hex
        if ($fopen("./mem/imem2.hex", "r"))
            $readmemh("./mem/imem2.hex", memory);
        else if ($fopen("./mem/imem.hex", "r"))
            $readmemh("./mem/imem.hex", memory);
        else
            $display("IMEM: No initial memory file found (imem2.hex or imem.hex).");
    end
endmodule