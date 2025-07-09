module ALUdecoder(
    input  [1:0] alu_op,
    input  [2:0] funct3,
    input        funct7b5,
    output logic [3:0] alu_control
);
    always_comb begin
        alu_control = 4'b0010; 
        case (alu_op)
            2'b00: alu_control = 4'b0010; 
            2'b01: alu_control = 4'b0110; 
            2'b10: begin 
                case (funct3)
                    3'b000: alu_control = (funct7b5 ? 4'b0110 : 4'b0010); 
                    3'b111: alu_control = 4'b0000; 
                    3'b110: alu_control = 4'b0001; 
                    3'b010: alu_control = 4'b0111; 
                    default: alu_control = 4'b0010;
                endcase
            end
            default: alu_control = 4'b0010;
        endcase
    end
endmodule