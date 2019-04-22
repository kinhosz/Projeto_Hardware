module UC (
    
    input logic clock, reset,
    input logic [6:0]Op,
    output logic PC_Write,
    output logic [2:0]Seletor_Ula,
    output logic [2:0]mux_A_seletor,
    output logic [2:0]mux_B_seletor,
    output logic register_Inst_wr,
    output logic Data_Memory_wr,
    output logic bancoRegisters_wr,
    output logic [2:0]Mux_Banco_Reg_Seletor

    );
    
    typedef enum  { busca = 1, selecao = 2 , inicio = 0 } Esta;
    Esta estado = estado.first;
    
    always_ff @(posedge clock, posedge reset) // sincrono
    begin
        if(reset) estado <= inicio;
        else begin
            

            case(estado)
                busca:begin
                    PC_Write = 1;
                    Seletor_Ula = 3'd1;
                    mux_A_seletor = 3'd0;
                    mux_B_seletor = 3'd1;
                    register_Inst_wr = 1;


                end
                default :begin
                    PC_Write = 1;
                    Seletor_Ula = 3'd1;
                    mux_A_seletor = 3'd0;
                    mux_B_seletor = 3'd1;
                    register_Inst_wr = 1;
                end
            endcase
            //estado = estado.next;
        end
    end

    //always_comb begin 
       // case(Op)
            //7'd51: begin
                
                //end
            
            //default: begin

                //end
        //endcase
    //end


endmodule