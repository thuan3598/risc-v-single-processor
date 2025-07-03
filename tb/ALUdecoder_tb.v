`timescale 1ns / 1ps

module ALUdecoder_tb;

    // Khai báo biến test
    reg  [1:0] alu_op;
    reg  [2:0] funct3;
    reg        funct7b5;
    wire [3:0] alu_control;

    // Gọi module cần test
    ALUdecoder uut (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7b5(funct7b5),
        .alu_control(alu_control)
    );

    // In kết quả
    task print_result;
        begin
            $display("Time=%0t | alu_op=%b | funct3=%b | funct7b5=%b => alu_control=%b", 
                      $time, alu_op, funct3, funct7b5, alu_control);
        end
    endtask

    initial begin
        $display("---- Bắt đầu test ALUdecoder ----");

        // Test alu_op = 00 => ADD mặc định
        alu_op = 2'b00; funct3 = 3'b000; funct7b5 = 1'b0; #10; print_result();

        // Test alu_op = 01 => SUB (dùng trong branch)
        alu_op = 2'b01; funct3 = 3'b000; funct7b5 = 1'b0; #10; print_result();

        // Test R-type với alu_op = 10
        alu_op = 2'b10;

        // ADD (funct3 = 000, funct7b5 = 0)
        funct3 = 3'b000; funct7b5 = 1'b0; #10; print_result();

        // SUB (funct3 = 000, funct7b5 = 1)
        funct3 = 3'b000; funct7b5 = 1'b1; #10; print_result();

        // AND
        funct3 = 3'b111; funct7b5 = 1'bx; #10; print_result();

        // OR
        funct3 = 3'b110; funct7b5 = 1'bx; #10; print_result();

        // SLT
        funct3 = 3'b010; funct7b5 = 1'bx; #10; print_result();

        // Default case
        funct3 = 3'b001; funct7b5 = 1'bx; #10; print_result();

        $display("---- Kết thúc test ALUdecoder ----");
        $finish;
    end

endmodule
