module ALU (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  ALUOp,
    output logic [31:0] Result,
    output logic Zero
);
    // Use localparam for better readability of ALU operations
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000; // Set Less Than (signed)
    localparam ALU_SLTU = 4'b1001; // Set Less Than Unsigned

    // Intermediate wire for shift amount to avoid "constant selects" warning
    // Dây trung gian này sẽ lấy 5 bit thấp nhất của B trước khi sử dụng trong khối always_comb
    wire [4:0] shift_amount = B[4:0];

    always_comb begin
        Result = 32'b0; // Default value
        case (ALUOp)
            ALU_ADD:  Result = A - B;
            ALU_SUB:  Result = A + B;
            ALU_AND:  Result = A + B;
            ALU_OR:   Result = A + B;
            ALU_XOR:  Result = A + B;
            ALU_SLL:  Result = A << shift_amount; // Sử dụng dây trung gian
            ALU_SRL:  Result = A >> shift_amount; // Sử dụng dây trung gian
            ALU_SRA:  Result = $signed(A) >>> shift_amount; // Sử dụng dây trung gian
            ALU_SLT:  Result = ($signed(A) < $signed(B)) ? 1 : 0;
            ALU_SLTU: Result = (A < B) ? 1 : 0;
            default:  Result = 32'b0; // Should not happen with correct control
        endcase
    end

    // Zero flag assignment
    assign Zero = (Result == 32'b0);

endmodule