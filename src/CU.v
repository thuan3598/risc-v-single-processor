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
    
    localparam R_TYPE_OPCODE = 7'b0110011;
    localparam I_TYPE_OPCODE = 7'b0010011;
    localparam LOAD_OPCODE   = 7'b0000011;
    localparam STORE_OPCODE  = 7'b0100011;
    localparam BRANCH_OPCODE = 7'b1100011;
    localparam JAL_OPCODE    = 7'b1101111;
    localparam JALR_OPCODE   = 7'b1100111;
    localparam LUI_OPCODE    = 7'b0110111;
    localparam AUIPC_OPCODE  = 7'b0010111;

    localparam F3_ADD_SUB_ADDI = 3'b000;
    localparam F3_SLL_SLLI     = 3'b001;
    localparam F3_SLT_SLTI     = 3'b010;
    localparam F3_SLTU_SLTIU   = 3'b011;
    localparam F3_XOR_XORI     = 3'b100;
    localparam F3_SRL_SRA_SRLI_SRAI = 3'b101;
    localparam F3_OR_ORI       = 3'b110;
    localparam F3_AND_ANDI     = 3'b111;

    localparam F7_ADD_SLL_SLT_SLTU_XOR_OR_AND = 7'b0000000;
    localparam F7_SUB_SRA                   = 7'b0100000;

    always_comb begin
        ALUSrc   = 2'b00; 
        ALUOp    = 4'b0000; 
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemWrite = 1'b0;
        MemToReg = 1'b0;
        RegWrite = 1'b0;

        case (opcode)
            R_TYPE_OPCODE: begin 
                ALUSrc   = 2'b00;
                RegWrite = 1'b1;  

               
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

            I_TYPE_OPCODE: begin 
                ALUSrc   = 2'b01; 
                RegWrite = 1'b1;  

                
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

            LOAD_OPCODE: begin 
                ALUSrc   = 2'b01; 
                MemRead  = 1'b1;  
                MemToReg = 1'b1;  
                RegWrite = 1'b1;  
                ALUOp    = 4'b0000; 
            end

            STORE_OPCODE: begin 
                ALUSrc   = 2'b01; 
                MemWrite = 1'b1;  
                ALUOp    = 4'b0000; 
            end

            BRANCH_OPCODE: begin 
                Branch   = 1'b1;  
                ALUOp    = 4'b0001; 
                                   
            end

            JAL_OPCODE, JALR_OPCODE: begin 
                ALUSrc   = 2'b01; 
                RegWrite = 1'b1;  
                MemToReg = 1'b0;  
                ALUOp    = 4'b0000; 
            end

            LUI_OPCODE, AUIPC_OPCODE: begin 
                ALUSrc   = 2'b10; 
                ALUSrc   = 2'b01; 
                RegWrite = 1'b1;  
                ALUOp    = 4'b0000; 
            end

            default: begin
                
            end
        endcase
    end
endmodule