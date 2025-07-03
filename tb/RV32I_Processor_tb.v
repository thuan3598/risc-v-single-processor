`timescale 1ns / 1ps

module RV32I_Processor_tb;

    reg clk;
    reg rst_n;
    wire [31:0] PC_out_top;
    wire [31:0] Instruction_out_top;

    // Instantiate DUT (Device Under Test)
    RV32I_Processor dut (
        .clk(clk),
        .rst_n(rst_n),
        .PC_out_top(PC_out_top),
        .Instruction_out_top(Instruction_out_top)
    );

    // Clock generation: 10ns period
    always #5 clk = ~clk;

    initial begin
        $display("---- Bắt đầu mô phỏng RV32I_Processor ----");

        // Init signals
        clk = 0;
        rst_n = 0;

        // Reset trong 2 chu kỳ
        #12;
        rst_n = 1;

        // Chạy trong 50 chu kỳ
        repeat (50) begin
            @(posedge clk);
            $display("Time=%0t | PC = 0x%08h | Instruction = 0x%08h", $time, PC_out_top, Instruction_out_top);
        end

        $display("---- Kết thúc mô phỏng ----");
        $finish;
    end

endmodule


