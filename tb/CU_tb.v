`timescale 1ns / 1ps

module CU_tb;

    // Tín hiệu vào
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg [6:0] funct7;

    // Tín hiệu ra
    wire [1:0] ALUSrc;
    wire [3:0] ALUOp;
    wire Branch;
    wire MemRead;
    wire MemWrite;
    wire MemToReg;
    wire RegWrite;

    // Gọi mô-đun cần test
    CU uut (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .ALUSrc(ALUSrc),
        .ALUOp(ALUOp),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .MemToReg(MemToReg),
        .RegWrite(RegWrite)
    );

    task print_result;
        begin
            $display("Time=%0t | opcode=%b | funct3=%b | funct7=%b | ALUSrc=%b | ALUOp=%b | Branch=%b | MemRead=%b | MemWrite=%b | MemToReg=%b | RegWrite=%b",
                $time, opcode, funct3, funct7, ALUSrc, ALUOp, Branch, MemRead, MemWrite, MemToReg, RegWrite);
        end
    endtask

    initial begin
        $display("---- Bắt đầu test CU ----");

        // R-type: ADD
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        // R-type: SUB
        opcode = 7'b0110011; funct3 = 3'b000; funct7 = 7'b0100000; #10; print_result();

        // R-type: SRA
        opcode = 7'b0110011; funct3 = 3'b101; funct7 = 7'b0100000; #10; print_result();

        // I-type: ADDI
        opcode = 7'b0010011; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        // I-type: SRLI
        opcode = 7'b0010011; funct3 = 3'b101; funct7 = 7'b0000000; #10; print_result();

        // I-type: SRAI
        opcode = 7'b0010011; funct3 = 3'b101; funct7 = 7'b0100000; #10; print_result();

        // Load
        opcode = 7'b0000011; funct3 = 3'b010; funct7 = 7'b0000000; #10; print_result();

        // Store
        opcode = 7'b0100011; funct3 = 3'b010; funct7 = 7'b0000000; #10; print_result();

        // Branch: BEQ
        opcode = 7'b1100011; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        // JAL
        opcode = 7'b1101111; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        // JALR
        opcode = 7'b1100111; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        // Default case
        opcode = 7'b1111111; funct3 = 3'b000; funct7 = 7'b0000000; #10; print_result();

        $display("---- Kết thúc test CU ----");
        $finish;
    end

endmodule
