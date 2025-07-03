`timescale 1ns / 1ps

module IMEM_tb;

    reg [31:0] addr;
    wire [31:0] Instruction;

    // Instantiate IMEM
    IMEM uut (
        .addr(addr),
        .Instruction(Instruction)
    );

    // Gán dữ liệu test trực tiếp (bỏ qua file hex)
    initial begin
        // Override bộ nhớ để test thủ công
        uut.memory[0] = 32'h12345678;
        uut.memory[1] = 32'h9abcdef0;
        uut.memory[127] = 32'hfeedbeef;
    end

    initial begin
        $display("---- Bắt đầu test IMEM ----");

        // Truy cập địa chỉ hợp lệ
        addr = 32'h00000000; #5;
        $display("addr = 0x%h => Instruction = 0x%h", addr, Instruction);

        addr = 32'h00000004; #5;
        $display("addr = 0x%h => Instruction = 0x%h", addr, Instruction);

        addr = 32'h000001FC; // dòng 127
        #5;
        $display("addr = 0x%h => Instruction = 0x%h", addr, Instruction);

        // Truy cập địa chỉ vượt giới hạn
        addr = 32'h00000200; // dòng 128
        #5;
        $display("addr = 0x%h => Instruction = 0x%h (mong đợi HALT 0x00000063)", addr, Instruction);

        addr = 32'h00000300; // dòng 192
        #5;
        $display("addr = 0x%h => Instruction = 0x%h (mong đợi HALT 0x00000063)", addr, Instruction);

        $display("---- Kết thúc test IMEM ----");
        $finish;
    end

endmodule
