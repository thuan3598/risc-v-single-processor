module branchComp (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic Branch,
    input  logic [2:0] funct3,
    output logic BrTaken
);
    // Use localparam for better readability of branch types
    localparam BEQ  = 3'b000; // Branch Equal
    localparam BNE  = 3'b001; // Branch Not Equal
    localparam BLT  = 3'b100; // Branch Less Than (signed)
    localparam BGE  = 3'b101; // Branch Greater Than or Equal (signed)
    localparam BLTU = 3'b110; // Branch Less Than Unsigned
    localparam BGEU = 3'b111; // Branch Greater Than or Equal Unsigned

    always_comb begin
        BrTaken = 1'b0; // Default to no branch taken
        if (Branch) begin // Only evaluate if it's a branch instruction
            if (funct3 == BEQ) begin
                BrTaken = (A == B);
            end else if (funct3 == BNE) begin
                BrTaken = (A != B);
            end else if (funct3 == BLT) begin
                BrTaken = ($signed(A) < $signed(B));
            end else if (funct3 == BGE) begin
                BrTaken = ($signed(A) >= $signed(B));
            end else if (funct3 == BLTU) begin
                BrTaken = (A < B);
            end else if (funct3 == BGEU) begin
                BrTaken = (A >= B);
            end
            // For any other funct3, BrTaken remains 0
        end
    end
endmodule
