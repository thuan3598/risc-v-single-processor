`timescale 1ns / 1ps

module DMEM_tb;

    reg clk;
    reg rst_n;
    reg MemRead;
    reg MemWrite;
    reg [31:0] addr;
    reg [31:0] WriteData;
    wire [31:0] ReadData;

    // Instantiate module
    DMEM dut (
        .clk(clk),
        .rst_n(rst_n),
        .MemRead(MemRead),
        .MemWrite(MemWrite),
        .addr(addr),
        .WriteData(WriteData),
        .ReadData(ReadData)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("---- Bắt đầu test DMEM ----");
        clk = 0;
        rst_n = 0;
        MemRead = 0;
        MemWrite = 0;
        addr = 0;
        WriteData = 0;

        // Reset
        #10;
        rst_n = 1;
        #10;

        // Ghi dữ liệu vào địa chỉ 0x08 (addr[9:2] = 2)
        addr = 32'h08;
        WriteData = 32'hABCD1234;
        MemWrite = 1;
        #10;

        // Ngừng ghi, chuyển sang đọc
        MemWrite = 0;
        MemRead = 1;
        #10;

        $display("Đọc tại addr = %h, kết quả ReadData = %h", addr, ReadData);

        // Kiểm tra reset lại
        rst_n = 0; #10;
        rst_n = 1; #10;
        MemRead = 1;
        #10;

        $display("Sau reset, đọc tại addr = %h, ReadData = %h (mong đợi 0)", addr, ReadData);

        $display("---- Kết thúc test DMEM ----");
        $finish;
    end

endmodule
