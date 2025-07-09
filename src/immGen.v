module immGen (
    input  logic [31:0] inst,
    output logic [31:0] imm_out
);
    wire [6:0] opcode = inst[6:0];

    localparam I_TYPE_OPCODE   = 7'b0010011; // ADDI, SLTI, SLTIU, ANDI, ORI, XORI, SLLI, SRLI, SRAI
    localparam LOAD_OPCODE     = 7'b0000011; // LW, LH, LB, LHU, LBU
    localparam JALR_OPCODE     = 7'b1100111; // JALR
    localparam S_TYPE_OPCODE   = 7'b0100011; // SW, SH, SB
    localparam B_TYPE_OPCODE   = 7'b1100011; // BEQ, BNE, BLT, BGE, BLTU, BGEU
    localparam AUIPC_OPCODE    = 7'b0010111; // AUIPC
    localparam LUI_OPCODE      = 7'b0110111; // LUI
    localparam J_TYPE_OPCODE   = 7'b1101111; // JAL

    wire inst_bit_31 = inst[31];
    wire [31:20] inst_bits_31_20 = inst[31:20];
    wire [31:25] inst_bits_31_25 = inst[31:25];
    wire [11:7] inst_bits_11_7 = inst[11:7];
    wire inst_bit_7 = inst[7];
    wire [30:25] inst_bits_30_25 = inst[30:25];
    wire [11:8] inst_bits_11_8 = inst[11:8];
    wire [31:12] inst_bits_31_12 = inst[31:12];
    wire [19:12] inst_bits_19_12 = inst[19:12];
    wire inst_bit_20 = inst[20];
    wire [30:21] inst_bits_30_21 = inst[30:21];


    always_comb begin
        imm_out = 32'b0;

        case (opcode)
            I_TYPE_OPCODE, LOAD_OPCODE, JALR_OPCODE: begin // I-type immediate
                imm_out = {{20{inst_bit_31}}, inst_bits_31_20}; 
            end

            S_TYPE_OPCODE: begin // S-type immediate
                imm_out = {{20{inst_bit_31}}, inst_bits_31_25, inst_bits_11_7}; 
            end

            B_TYPE_OPCODE: begin // B-type immediate (branch)
                // Format: imm[12|10:5|4:1|11] << 1
                imm_out = {{19{inst_bit_31}}, inst_bit_31, inst_bit_7, inst_bits_30_25, inst_bits_11_8, 1'b0}; 
            end

            AUIPC_OPCODE, LUI_OPCODE: begin // U-type immediate (AUIPC, LUI)
                // Format: imm[31:12] << 12
                imm_out = {inst_bits_31_12, 12'b0}; 
            end

            J_TYPE_OPCODE: begin // J-type immediate (JAL)
                // Format: imm[20|10:1|11|19:12] << 1
                imm_out = {{11{inst_bit_31}}, inst_bit_31, inst_bits_19_12, inst_bit_20, inst_bits_30_21, 1'b0}; 
            end

            default: begin
                imm_out = 32'b0; 
            end
        endcase
    end
endmodule