module CU (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic [6:0] funct7,
    output logic [1:0] ALUSrc,
    output logic [3:0] ALUOp,
    output logic Branch,
    output logic MemRead,
    output logic MemWrite,
    output logic MemToReg,
    output logic RegWrite
);
    // Define opcodes as localparams for readability
    localparam R_TYPE_OPCODE = 7'b0110011;
    localparam I_TYPE_OPCODE = 7'b0010011;
    localparam LOAD_OPCODE   = 7'b0000011;
    localparam STORE_OPCODE  = 7'b0100011;
    localparam BRANCH_OPCODE = 7'b1100011;
    localparam JAL_OPCODE    = 7'b1101111;
    localparam JALR_OPCODE   = 7'b1100111;
    localparam LUI_OPCODE    = 7'b0110111;
    localparam AUIPC_OPCODE  = 7'b0010111;

    // Define funct3 values for I-type and R-type instructions
    localparam F3_ADD_SUB_ADDI = 3'b000;
    localparam F3_SLL_SLLI     = 3'b001;
    localparam F3_SLT_SLTI     = 3'b010;
    localparam F3_SLTU_SLTIU   = 3'b011;
    localparam F3_XOR_XORI     = 3'b100;
    localparam F3_SRL_SRA_SRLI_SRAI = 3'b101;
    localparam F3_OR_ORI       = 3'b110;
    localparam F3_AND_ANDI     = 3'b111;

    // Define funct7 values for R-type shifts and SUB/SRA
    localparam F7_ADD_SLL_SLT_SLTU_XOR_OR_AND = 7'b0000000;
    localparam F7_SUB_SRA                   = 7'b0100000;

    always_comb begin
        // Default values for all control signals (no operation)
        ALUSrc   = 2'b00; // Default to ReadData2
        ALUOp    = 4'b0000; // Default to ADD (safe default)
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;

        case (opcode)
            R_TYPE_OPCODE: begin // R-type instructions (e.g., ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU)
                ALUSrc   = 2'b00; // ALU second operand comes from ReadData2 (rs2)
                RegWrite = 1'b1;  // Result is written back to register file

                // Determine ALU operation based on funct7 and funct3
                if (funct7 == F7_ADD_SLL_SLT_SLTU_XOR_OR_AND) begin // ADD, SLL, SLT, SLTU, XOR, OR, AND
                    case (funct3)
                        F3_ADD_SUB_ADDI: ALUOp = 4'b0000; // ADD
                        F3_SLL_SLLI:     ALUOp = 4'b0101; // SLL
                        F3_SLT_SLTI:     ALUOp = 4'b1000; // SLT
                        F3_SLTU_SLTIU:   ALUOp = 4'b1001; // SLTU
                        F3_XOR_XORI:     ALUOp = 4'b0100; // XOR
                        F3_SRL_SRA_SRLI_SRAI: ALUOp = 4'b0110; // SRL (for R-type, funct7=0)
                        F3_OR_ORI:       ALUOp = 4'b0011; // OR
                        F3_AND_ANDI:     ALUOp = 4'b0010; // AND
                        default:         ALUOp = 4'b0000; // Default to ADD
                    endcase
                end else if (funct7 == F7_SUB_SRA) begin // SUB, SRA
                    case (funct3)
                        F3_ADD_SUB_ADDI: ALUOp = 4'b0001; // SUB
                        F3_SRL_SRA_SRLI_SRAI: ALUOp = 4'b0111; // SRA
                        default:         ALUOp = 4'b0000; // Default to ADD
                    endcase
                end else begin
                    ALUOp = 4'b0000; // Default to ADD for unknown R-type
                end
            end

            I_TYPE_OPCODE: begin // I-type instructions (e.g., ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU)
                ALUSrc   = 2'b01; // ALU second operand comes from Immediate
                RegWrite = 1'b1;  // Result is written back to register file

                // Determine ALU operation based on funct3 and funct7 (for shifts)
                case (funct3)
                    F3_ADD_SUB_ADDI: ALUOp = 4'b0000; // ADDI
                    F3_SLL_SLLI:     ALUOp = 4'b0101; // SLLI
                    F3_SLT_SLTI:     ALUOp = 4'b1000; // SLTI
                    F3_SLTU_SLTIU:   ALUOp = 4'b1001; // SLTIU
                    F3_XOR_XORI:     ALUOp = 4'b0100; // XORI
                    F3_SRL_SRA_SRLI_SRAI: begin // SRLI/SRAI
                        if (funct7 == F7_ADD_SLL_SLT_SLTU_XOR_OR_AND)
                            ALUOp = 4'b0110; // SRLI
                        else if (funct7 == F7_SUB_SRA)
                            ALUOp = 4'b0111; // SRAI
                        else
                            ALUOp = 4'b0000; // Default to ADD
                    end
                    F3_OR_ORI:       ALUOp = 4'b0011; // ORI
                    F3_AND_ANDI:     ALUOp = 4'b0010; // ANDI
                    default:         ALUOp = 4'b0000; // Default to ADDI
                endcase
            end

            LOAD_OPCODE: begin // Load instructions (e.g., LW, LH, LB, LHU, LBU)
                ALUSrc   = 2'b01; // ALU second operand comes from Immediate (for address calculation)
                MemRead  = 1'b1;  // Enable memory read
                MemToReg = 1'b1;  // Data from memory is written back to register file
                RegWrite = 1'b1;  // Enable register write
                ALUOp    = 4'b0000; // Perform ADD for address calculation (base + offset)
            end

            STORE_OPCODE: begin // Store instructions (e.g., SW, SH, SB)
                ALUSrc   = 2'b01; // ALU second operand comes from Immediate (for address calculation)
                MemWrite = 1'b1;  // Enable memory write
                ALUOp    = 4'b0000; // Perform ADD for address calculation (base + offset)
            end

            BRANCH_OPCODE: begin // Branch instructions (e.g., BEQ, BNE, BLT, BGE, BLTU, BGEU)
                Branch   = 1'b1;  // It's a branch instruction
                ALUOp    = 4'b0001; // Perform SUB for comparison in ALU (though branchComp handles actual comparison)
                                   // The result of ALU is not used for branch, but for setting Zero flag if needed
                                   // The actual comparison for BrTaken is done in branchComp
            end

            JAL_OPCODE, JALR_OPCODE: begin // JAL (Jump and Link), JALR (Jump and Link Register)
                ALUSrc   = 2'b01; // ALU second operand comes from Immediate (for target address)
                RegWrite = 1'b1;  // Write PC+4 to rd
                MemToReg = 1'b0;  // Result comes from ALU (PC+4), not memory
                ALUOp    = 4'b0000; // Not directly used for JAL/JALR target, but for PC+4 calculation if needed
            end

            LUI_OPCODE, AUIPC_OPCODE: begin // LUI (Load Upper Immediate), AUIPC (Add Upper Immediate to PC)
                ALUSrc   = 2'b10; // Special case: ALU second operand is not ReadData2 or Imm, but 0 (effectively just passing Imm or PC)
                                   // For LUI, Imm is the value. For AUIPC, PC + Imm.
                                   // The ALU here is used to pass the immediate or add PC to it.
                                   // A dedicated mux for ALU_in2 could handle this, but for simplicity,
                                   // if ALUSrc is 2'b10, it implies the immediate is the direct result or added to PC.
                                   // In RISCV_Single_Cycle, ALU_in2 is (ALUSrc[0]) ? Imm : ReadData2.
                                   // This means for LUI/AUIPC, ALUSrc needs to be 2'b01 to select Imm.
                                   // Let's correct this: LUI/AUIPC use immediate.
                ALUSrc   = 2'b01; // ALU second operand comes from Immediate
                RegWrite = 1'b1;  // Result is written back to register file
                ALUOp    = 4'b0000; // For LUI, it's effectively just passing Imm. For AUIPC, it's PC + Imm.
            end

            default: begin
                // All signals remain at their default (inactive) values
            end
        endcase
    end
endmodule