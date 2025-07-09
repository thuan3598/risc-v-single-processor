module DMEM (
    input logic clk,
    input logic rst_n,
    input logic MemRead,
    input logic MemWrite,
    input logic [31:0] addr,
    input logic [31:0] WriteData,
    output logic [31:0] ReadData
);
    logic [31:0] memory [0:255]; // 256 words * 4 bytes/word = 1KB memory

    // Read data combinatorially
    assign ReadData = (MemRead) ? memory[addr[9:2]] : 32'b0;

    // Write data on positive clock edge
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset memory to all zeros
            for (int i = 0; i < 256; i = i + 1)
                memory[i] <= 32'b0;
        end else if (MemWrite) begin
            // Write data to memory at byte-aligned address
            memory[addr[9:2]] <= WriteData;
        end
    end

    // Initial memory loading from hex file (kept as requested)
    initial begin
        // Try loading from dmem_init2.hex first, then dmem_init.hex
        if ($fopen("./mem/dmem_init2.hex", "r"))
            $readmemh("./mem/dmem_init2.hex", memory);
        else if ($fopen("./mem/dmem_init.hex", "r"))
            $readmemh("./mem/dmem_init.hex", memory);
        else
            $display("DMEM: No initial memory file found (dmem_init2.hex or dmem_init.hex).");
    end
endmodule
