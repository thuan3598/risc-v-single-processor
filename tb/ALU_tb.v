`timescale 1ns / 1ps

module ALU_tb;

    // Khai báo biến test
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0]  ALUOp;
    wire [31:0] Result;
    wire        Zero;

    // Gọi module ALU
    ALU uut (
        .A(A),
        .B(B),
        .ALUOp(ALUOp),
        .Result(Result),
        .Zero(Zero)
    );

    // In kết quả ra console
    task print_result;
        begin
            $display("Time=%0t | ALUOp=%b | A=%0d | B=%0d | Result=%0d | Zero=%b", $time, ALUOp, A, B, Result, Zero);
        end
    endtask

    initial begin
        $display("---- Bắt đầu test ALU ----");

        A = 32'd10; B = 32'd5;

        // ADD
        ALUOp = 4'b0000; #10; print_result();
        // SUB
        ALUOp = 4'b0001; #10; print_result();
        // AND
        ALUOp = 4'b0010; #10; print_result();
        // OR
        ALUOp = 4'b0011; #10; print_result();
        // XOR
        ALUOp = 4'b0100; #10; print_result();
        // SLL (Shift left logical)
        ALUOp = 4'b0101; #10; print_result();
        // SRL (Shift right logical)
        ALUOp = 4'b0110; #10; print_result();
        // SRA (Shift right arithmetic)
        A = -32'sd20; B = 32'd2; ALUOp = 4'b0111; #10; print_result();
        // SLT (signed less than)
        A = -32'sd3; B = 32'sd2; ALUOp = 4'b1000; #10; print_result();
        // SLTU (unsigned less than)
        A = 32'd2; B = 32'd3; ALUOp = 4'b1001; #10; print_result();

        // Kiểm tra bit Zero
        A = 32'd5; B = 32'd5; ALUOp = 4'b0001; #10; print_result(); // SUB → 0

        $display("---- Kết thúc test ALU ----");
        $finish;
    end

endmodule
