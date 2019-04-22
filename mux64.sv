module mux64
(   
    input [2:0] Sel, 
    input logic [63:0] A, 
    input logic [63:0] B, 
    input logic [63:0] C, 
    input logic [63:0] D,
    output logic [63:0] Saida);

    reg [2:0] Seletor;
    initial begin
        Seletor = Sel;
    end
    always @(Sel)begin
        Seletor = Sel;
    end
    
    always @(Seletor) begin
        
        case(Seletor)
            3'd00: begin
                Saida = A;
            end
            3'd01: begin
                Saida = B;
            end
            3'd02: begin
                Saida = C;
            end
            3'd03: begin
                Saida = D ;
            end
            default: begin
                Saida = 64'd66;
            end
        endcase
    end
endmodule
