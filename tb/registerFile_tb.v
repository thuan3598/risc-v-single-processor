`timescale 1ns / 1ps

module registerFile_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg RegWrite;
    reg [4:0] rs1, rs2, rd;
    reg [31:0] WriteData;

    // Outputs
    wire [31:0] ReadData1, ReadData2;

    // Instantiate DUT
    registerFile uut (
        .clk(clk),
        .rst_n(rst_n),
        .RegWrite(RegWrite),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .WriteData(WriteData),
        .ReadData1(ReadData1),
        .ReadData2(ReadData2)
    );

    // Clock generator
    always #5 clk = ~clk;

    initial begin
        $display("---- Bắt đầu test registerFile ----");

        // Initial values
        clk = 0;
        rst_n = 0;
        RegWrite = 0;
        rs1 = 0; rs2 = 0; rd = 0;
        WriteData = 0;

        // Apply reset
        #10;
        rst_n = 1; #10;

        // Ghi 0x12345678 vào thanh ghi x5
        RegWrite = 1;
        rd = 5;
        WriteData = 32'h12345678;
        #10; // rising edge

        // Đọc lại từ x5
        RegWrite = 0;
        rs1 = 5;
        rs2 = 0;
        #10;
        $display("ReadData1 (x5) = 0x%h (mong đợi 0x12345678)", ReadData1);

        // Ghi vào thanh ghi x0 (không được ghi)
        RegWrite = 1;
        rd = 0;
        WriteData = 32'hFFFFFFFF;
        #10;

        // Đọc lại từ x0
        RegWrite = 0;
        rs1 = 0;
        rs2 = 0;
        #10;
        $display("ReadData1 (x0) = 0x%h (mong đợi 0x00000000)", ReadData1);

        // Reset lại và kiểm tra thanh ghi x5 đã bị xóa
        rst_n = 0; #10;
        rst_n = 1; #10;
        rs1 = 5; #10;
        $display("Sau reset, ReadData1 (x5) = 0x%h (mong đợi 0)", ReadData1);

        $display("---- Kết thúc test registerFile ----");
        $finish;
    end

endmodule
