`timescale 1ns / 1ps

module branchComp_tb;

    // Khai báo tín hiệu
    reg  [31:0] A, B;
    reg        Branch;
    reg  [2:0] funct3;
    wire       BrTaken;

    // Gọi mô-đun branchComp
    branchComp uut (
        .A(A),
        .B(B),
        .Branch(Branch),
        .funct3(funct3),
        .BrTaken(BrTaken)
    );

    // In kết quả ra console
    task print_result;
        begin
            $display("Time=%0t | Branch=%b | funct3=%b | A=%0d | B=%0d | BrTaken=%b",
                      $time, Branch, funct3, A, B, BrTaken);
        end
    endtask

    initial begin
        $display("---- Bắt đầu test branchComp ----");

        // Kích hoạt Branch
        Branch = 1;

        // BEQ: A == B
        funct3 = 3'b000;
        A = 10; B = 10; #10; print_result();
        A = 10; B = 5;  #10; print_result();

        // BNE: A != B
        funct3 = 3'b001;
        A = 10; B = 5;  #10; print_result();
        A = 8;  B = 8;  #10; print_result();

        // BLT: signed A < B
        funct3 = 3'b100;
        A = -5; B = 3;  #10; print_result();
        A = 5;  B = -3; #10; print_result();

        // BGE: signed A >= B
        funct3 = 3'b101;
        A = 5;  B = -3; #10; print_result();
        A = -5; B = 3;  #10; print_result();

        // BLTU: unsigned A < B
        funct3 = 3'b110;
        A = 32'h00000001; B = 32'hFFFFFFFF; #10; print_result();
        A = 32'hFFFFFFFE; B = 32'h00000001; #10; print_result();

        // BGEU: unsigned A >= B
        funct3 = 3'b111;
        A = 32'hFFFFFFFF; B = 32'h00000001; #10; print_result();
        A = 32'h00000001; B = 32'hFFFFFFFF; #10; print_result();

        // Trường hợp Branch không kích hoạt
        Branch = 0;
        funct3 = 3'b000;
        A = 10; B = 10; #10; print_result();

        $display("---- Kết thúc test branchComp ----");
        $finish;
    end

endmodule
