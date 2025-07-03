`timescale 1ns / 1ps

module immGen_tb;

    reg  [31:0] inst;
    wire [31:0] imm_out;

    // Instantiate DUT
    immGen uut (
        .inst(inst),
        .imm_out(imm_out)
    );

    // Task hiển thị kết quả
    task print_result;
        begin
            $display("Time=%0t | inst=0x%h | imm_out=0x%h (%0d)", $time, inst, imm_out, imm_out);
        end
    endtask

    initial begin
        $display("---- Bắt đầu test immGen ----");

        // I-type: addi x1, x2, -12 => opcode = 0010011
        inst = 32'b111111111100_00010_000_00001_0010011; #10; print_result();

        // S-type: sw x1, -8(x2) => opcode = 0100011
        inst = 32'b1111111_00001_00010_010_01000_0100011; #10; print_result();

        // B-type: beq x1, x2, -4 => opcode = 1100011
        inst = 32'b111111_00010_00001_000_11110_1100011; #10; print_result();

        // U-type: lui x1, 0x12345 => opcode = 0110111
        inst = 32'b00010010001101000101_00001_0110111; #10; print_result();

        // U-type: auipc x1, 0xABCDE => opcode = 0010111
        inst = 32'b10101011110011011110_00001_0010111; #10; print_result();

        // J-type: jal x1, 2048 => opcode = 1101111
        inst = 32'b000000000010_00000000_0_00000001_1101111; #10; print_result();

        // J-type: jal x1, -4 => immediate = 0xFFFFFFFC
        inst = 32'b11111111111111111111_00001_1101111; #10; print_result();

        // Mặc định
        inst = 32'b0; #10; print_result();

        $display("---- Kết thúc test immGen ----");
        $finish;
    end

endmodule
