module RISCV_Single_Cycle(
    input logic clk,
    input logic rst_n,
    output logic [31:0] PC_out_top,
    output logic [31:0] Instruction_out_top
);

    // Program Counter (PC) related signals
    logic [31:0] PC_current; // Current PC value
    logic [31:0] PC_next;    // Next PC value

    // Instruction fields extracted from Instruction_out_top
    logic [4:0] rs1_addr, rs2_addr, rd_addr;
    logic [2:0] inst_funct3;
    logic [6:0] inst_opcode, inst_funct7;

    // Immediate value from immGen
    logic [31:0] immediate_value;

    // Register file read data
    logic [31:0] reg_read_data1, reg_read_data2;
    // Data to be written back to register file
    logic [31:0] reg_write_data;

    // ALU input and output signals
    logic [31:0] alu_operand_B;
    logic [31:0] alu_result;
    logic alu_zero_flag;

    // Data Memory read data
    logic [31:0] mem_read_data;

    // Control signals from CU
    logic [1:0] ctrl_ALUSrc;
    logic [3:0] ctrl_ALUOp;
    logic ctrl_Branch;
    logic ctrl_MemRead;
    logic ctrl_MemWrite;
    logic ctrl_MemToReg;
    logic ctrl_RegWrite;

    // Branch comparator output
    logic branch_taken_flag;

 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            PC_current <= 32'b0; // Reset PC to 0
        else
            PC_current <= PC_next; // Update PC to the next calculated value
    end

    // Output current PC and Instruction for external observation/debugging
    assign PC_out_top = PC_current;

    // Instruction Memory (IMEM) instance
    IMEM IMEM_inst(
        .addr(PC_current),
        .Instruction(Instruction_out_top)
    );

    // Instruction field decoding (combinatorial)
    assign inst_opcode = Instruction_out_top[6:0];
    assign rd_addr     = Instruction_out_top[11:7];
    assign inst_funct3 = Instruction_out_top[14:12];
    assign rs1_addr    = Instruction_out_top[19:15];
    assign rs2_addr    = Instruction_out_top[24:20];
    assign inst_funct7 = Instruction_out_top[31:25];

    // Immediate Generator instance
    immGen imm_gen(
        .inst(Instruction_out_top),
        .imm_out(immediate_value)
    );

    // Register File instance
    registerFile Reg_inst(
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(ctrl_RegWrite),
        .rs1(rs1_addr),
        .rs2(rs2_addr),
        .rd(rd_addr),
        .WriteData(reg_write_data),
        .ReadData1(reg_read_data1),
        .ReadData2(reg_read_data2)
    );

    assign alu_operand_B = (ctrl_ALUSrc[0]) ? immediate_value : reg_read_data2;

    // ALU instance
    ALU alu(
        .A(reg_read_data1),
        .B(alu_operand_B),
        .ALUOp(ctrl_ALUOp),
        .Result(alu_result),
        .Zero(alu_zero_flag) // Zero flag from ALU (not directly used for branch in this structure, but good for debugging)
    );

    // Data Memory (DMEM) instance
    DMEM DMEM_inst(
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(ctrl_MemRead),
        .MemWrite(ctrl_MemWrite),
        .addr(alu_result), // ALU result is the memory address
        .WriteData(reg_read_data2), // Data to write comes from rs2
        .ReadData(mem_read_data)
    );

    assign reg_write_data = (ctrl_MemToReg) ? mem_read_data : alu_result;

    // Control Unit (CU) instance
    CU ctrl(
        .opcode(inst_opcode),
        .funct3(inst_funct3),
        .funct7(inst_funct7),
        .ALUSrc(ctrl_ALUSrc),
        .ALUOp(ctrl_ALUOp),
        .Branch(ctrl_Branch),
        .MemRead(ctrl_MemRead),
        .MemWrite(ctrl_MemWrite),
        .MemToReg(ctrl_MemToReg),
        .RegWrite(ctrl_RegWrite)
    );


    branchComp comp(
        .A(reg_read_data1),
        .B(reg_read_data2),
        .Branch(ctrl_Branch),
        .funct3(inst_funct3),
        .BrTaken(branch_taken_flag)
    );

    assign PC_next = (branch_taken_flag) ? PC_current + immediate_value : PC_current + 32'd4;

endmodule