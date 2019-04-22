module UC (
    
    input logic clock, reset,
    input logic [31:0]Register_Intruction_Instr31_0,
    input logic z,      //flag que indica se o resultado da operação foi 0
    input logic igual,  //flag que indica se A=B
    input logic maior,  //flag que indica se A>B
    input logic menor,  //flag que indica se A<B
    output logic PC_Write,
    output logic [2:0]Seletor_Ula,
    output logic [2:0]mux_A_seletor,
    output logic [2:0]mux_B_seletor,
    output logic register_Inst_wr,
    output logic Data_Memory_wr,
    output logic bancoRegisters_wr,
    output logic reset_A, //bit de sinal que zera(reseta) o registrador A
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
                    PC_Write <= 1;
                    Seletor_Ula <= 3'd1;
                    mux_A_seletor <= 3'd0;
                    mux_B_seletor <= 3'd1;
                end
                selecao:begin
                    PC_Write <= 0; //PC para de ler instrucao
                    case(Register_Intruction_Instr31_0[6:0])
                        7'd51: begin //tipo R
                            if(Register_Intruction_Instr31_0[14:12]==3'd0 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //add rd, rs1, rs2
                                Seletor_Ula <= 3'd1;        //Operação soma
                                mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                mux_B_seletor <= 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                            end
                            else begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd0 && Register_Intruction_Instr31_0[31:25]==7'd32) begin //sub rd, rs1, rs2
                                    Seletor_Ula <= 3'd1;        //Operação subtração
                                    mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor <= 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                    Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                    bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd7 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //and rd, rs1, rs2
                                        Seletor_Ula <= 3'd3;        //Operação AND
                                        mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                        mux_B_seletor <= 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                        Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                        bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd2 && Register_Intruction_Instr31_0[31:25]==7'd0) begin //slt rd, rs1, rs2
                                            Seletor_Ula <= 3'd7;        //Operação comparação
                                            mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor <= 3'd0;      //Valor contido em rs2 sai do MUX de baixo
                                            if(menor==1) begin             //Se rs1<rs2
                                                Seletor_Ula <= 3'd4;        //Operação incremento de A
                                                reset_A <= 1;               //A gente tem que zerar o registrador A
                                                mux_A_seletor <= 3'd1;      //Valor contido em A(A=1) sai do MUX de cima
                                                Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                                bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                            end
                                            else begin
                                                if(menor==0) begin             //Se rs1>=rs2
                                                    Seletor_Ula <= 3'd0;        //Operação carregar A
                                                    reset_A <= 1;               //A gente tem que zerar o registrador A
                                                    mux_A_seletor <= 3'd1;      //Valor contido em A(A=0) sai do MUX de cima
                                                    Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                                    bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd 
                                                end
                                            end         
                                        end
                                    end
                                end            
                            end
                        end
                        7'd19: begin //tipo I
                            if(Register_Intruction_Instr31_0[31:7]==25'd0) begin //nop
                                estado <= estado.first;
                            end
                            else begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //addi rd, rs1, immediate
                                    Seletor_Ula <= 3'd1;        //Operação soma(com constante)
                                    mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor <= 3'd2;      //Valor contido em immediate sai do MUX de baixo
                                    Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                    bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //slti rd, rs1, immediate
                                        Seletor_Ula <= 3'd7;        //Operação comparação
                                        mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                        mux_B_seletor <= 3'd2;      //Valor immediate sai do MUX de baixo
                                        if(menor==1) begin             //Se rs1<immediate
                                            Seletor_Ula <= 3'd4;        //Operação incremento de A
                                            reset_A <= 1;               //A gente tem que zerar o registrador A
                                            mux_A_seletor <= 3'd1;      //Valor contido em A(A=1) sai do MUX de cima
                                            Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                            bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                        end
                                        else begin
                                            if(menor==0) begin             //Se rs1>=immediate
                                                Seletor_Ula <= 3'd0;        //Operação carregar A
                                                reset_A <= 1;               //A gente tem que zerar o registrador A
                                                mux_A_seletor <= 3'd1;      //Valor contido em A(A=0) sai do MUX de cima
                                                Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                                bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                            end
                                        end
                                    end
                                    else begin //tipo I(shifts)
                                         if(Register_Intruction_Instr31_0[14:12]==3'd5 && Register_Intruction_Instr31_0[31:26]==6'd0) begin //srli rd, rs1, shamt
                                            Seletor_Ula <= 3'd0;        //Operação carregar A
                                            mux_A_seletor <= 3'd1;      //Valor contido em A sai do MUX de cima
                                            Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                            bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                         end
                                         else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd5 && Register_Intruction_Instr31_0[31:26]==6'd16) begin //srai rd, rs1, shamt
                                                Seletor_Ula <= 3'd0;        //Operação carregar A
                                                mux_A_seletor <= 3'd1;      //Valor contido em A sai do MUX de cima
                                                Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                                bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                            end
                                            else begin
                                                if(Register_Intruction_Instr31_0[14:12]==3'd1 && Register_Intruction_Instr31_0[31:26]==6'd0) begin //slli rd, rs1, shamt
                                                    Seletor_Ula <= 3'd0;        //Operação carregar A
                                                    mux_A_seletor <= 3'd1;      //Valor contido em A sai do MUX de cima
                                                    Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                                    bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                                end
                                            end    
                                        end
                                    end    
                                end
                            end
                        end
                        7'd115: begin //tipo I -> break
                            mux_A_seletor <= 3'd0;      //Valor contido em PC sai do MUX de cima
                            Seletor_Ula <= 3'd0;        //Operação carregar A(PC)
                        end                                
                        7'd3: begin //tipo I
                            if(Register_Intruction_Instr31_0[14:12]==3'd3) begin //ld rd, imm(rs1)
                                Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd
                            end
                            else begin//a gente tem que ligar a memória a um extensor de sinal adicional só pra pra lidar com esses loads 
                                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //lb rd, imm(rs1)
                                    Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                    mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                    mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                    Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                    Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                    bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[7:0]
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //lh rd, imm(rs1)
                                        Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                        mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                        mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                        Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                        Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                        bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[15:0]
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //lw rd, imm(rs1)
                                            Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                            mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                            mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                            Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                            Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                            bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[31:0]
                                        end
                                        else begin
                                            if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //lbu rd, imm(rs1)
                                                Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                                mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                                Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                                bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[7:0]
                                            end
                                            else begin
                                                if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //lhu rd, imm(rs1)
                                                    Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                                    mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                    mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                    Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                                    Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                                    bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[15:0]
                                                end
                                                else begin
                                                    if(Register_Intruction_Instr31_0[14:12]==3'd6) begin //lwu rd, imm(rs1)
                                                        Seletor_Ula <= 3'd1;         //Operação soma(com constante e endereço)
                                                        mux_A_seletor <= 3'd1;       //Endereço contido em rs1 sai do MUX de cima
                                                        mux_B_seletor <= 3'd2;       //Valor contido em immediate sai do MUX de baixo
                                                        Data_Memory_wr <= 0;         //Permite que o valor no endereço rs1+immediate(ALU_OUT) seja lido
                                                        Mux_Banco_Reg_Seletor <= 1;  //O valor lido da memória de dados vai para datain no banco de registradores
                                                        bancoRegisters_wr <= 1;      //Permitirá ao banco de registradores escrever o valor(datain) lido da memória de dados em rd[31:0]
                                                    end
                                                end
                                            end    
                                        end    
                                    end
                                end
                            end
                        end
                        7'd35: begin //tipo S
                            if(Register_Intruction_Instr31_0[14:12]==3'd7) begin //sd rs2, imm(rs1)
                                Seletor_Ula <= 3'd1;    //Operação soma(com constante e endereço)
                                mux_A_seletor <= 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                mux_B_seletor <= 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                Data_Memory_wr <= 1;    //Permite a memória de dados guardar valor de rs2 no endereço rs1+immediate
                            end
                            else begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sw rs2, imm(rs1)
                                    Seletor_Ula <= 3'd1;    //Operação soma(com constante e endereço)
                                    mux_A_seletor <= 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                    mux_B_seletor <= 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                    Data_Memory_wr <= 1;    //Permite a memória de dados guardar valor de rs2[31:0] no endereço rs1+immediate
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sh rs2, imm(rs1)
                                        Seletor_Ula <= 3'd1;    //Operação soma(com constante e endereço)
                                        mux_A_seletor <= 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                        mux_B_seletor <= 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                        Data_Memory_wr <= 1;    //Permite a memória de dados guardar valor de rs2[15:0] no endereço rs1+immediate
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd2) begin //sb rs2, imm(rs1)
                                            Seletor_Ula <= 3'd1;    //Operação soma(com constante e endereço)
                                            mux_A_seletor <= 3'd1;  //Endereço contido em rs1 sai do MUX de cima
                                            mux_B_seletor <= 3'd2;  //Valor contido em immediate sai do MUX de baixo
                                            Data_Memory_wr <= 1;    //Permite a memória de dados guardar valor de rs2[7:0] no endereço rs1+immediate
                                        end
                                    end    
                                end    
                            end    
                        end
                        7'd99: begin //tipo SB
                            if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //beq rs1, rs2, imm
                                Seletor_Ula <= 3'd7;    //Operação comparação
                                mux_A_seletor <= 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                mux_B_seletor <= 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                if(igual==1) begin         //se rs1=rs2
                                    Seletor_Ula <= 3'd1;    //Operação soma
                                    mux_A_seletor <= 3'd0;  //Endereço contido em PC sai do MUX de cima
                                    mux_B_seletor <= 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                end
                            end
                        end
                        7'd103: begin //tipo SB ou tipo I
                            if(Register_Intruction_Instr31_0[14:12]==3'd1) begin //bne rs1, rs2, imm
                                Seletor_Ula <= 3'd7;    //Operação comparação
                                mux_A_seletor <= 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                mux_B_seletor <= 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                if(igual==0) begin         //se rs1-rs2>0 ou rs1-rs2<0
                                    Seletor_Ula <= 3'd1;    //Operação soma
                                    mux_A_seletor <= 3'd0;  //Endereço contido em PC sai do MUX de cima
                                    mux_B_seletor <= 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                end
                            end
                            else begin
                                if(Register_Intruction_Instr31_0[14:12]==3'd0) begin //jalr rd, rs1, imm
                                    //rd = PC
                                    Seletor_Ula <= 3'd0;        //Operação carregar A
                                    mux_A_seletor <= 3'd0;      //Valor contido em PC sai do MUX de cima
                                    Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                                    bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                                    //PC = rs1 + imm
                                    Seletor_Ula <= 3'd1;        //Operação soma
                                    mux_A_seletor <= 3'd1;      //Valor contido em rs1 sai do MUX de cima
                                    mux_B_seletor <= 3'd2;      //Valor contido em immediate sai do MUX de baixo
                                end
                                else begin
                                    if(Register_Intruction_Instr31_0[14:12]==3'd5) begin //bge rs1, rs2, imm
                                        Seletor_Ula <= 3'd7;    //Operação comparação
                                        mux_A_seletor <= 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                        mux_B_seletor <= 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                        if(menor==0) begin         //se rs1>rs2 ou rs1=rs2
                                            Seletor_Ula <= 3'd1;    //Operação soma
                                            mux_A_seletor <= 3'd0;  //Endereço contido em PC sai do MUX de cima
                                            mux_B_seletor <= 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                        end    
                                    end
                                    else begin
                                        if(Register_Intruction_Instr31_0[14:12]==3'd4) begin //blt rs1, rs2, imm
                                            Seletor_Ula <= 3'd7;    //Operação comparação
                                            mux_A_seletor <= 3'd1;  //Valor contido em rs1 sai do MUX de cima
                                            mux_B_seletor <= 3'd0;  //Valor contido em rs2 sai do MUX de baixo
                                            if(menor==1) begin         //se rs1<rs2
                                                Seletor_Ula <= 3'd1;    //Operação soma
                                                mux_A_seletor <= 3'd0;  //Endereço contido em PC sai do MUX de cima
                                                mux_B_seletor <= 3'd3;  //Endereço contido em immediate sai do MUX de baixo
                                            end
                                        end        
                                    end     
                                end
                            end    
                        end
                        7'd55: begin //tipo U -> lui rd, imm
                            Seletor_Ula <= 3'd1;        //Operação soma
                            mux_A_seletor <= 3'd1;      //Valor contido em rs1(zerado) sai do MUX de cima
                            mux_B_seletor <= 3'd2;      //Valor contido em immediate[31:12] com o lado direito[11:0] zerado e com sinal extendido sai do MUX de baixo
                            Mux_Banco_Reg_Seletor <= 0; //O valor que sai da ALU vai para datain no banco de registradores
                            bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o valor(datain) em rd
                        end
                        7'd111: begin //tipo UJ -> jal rd, imm
                            //rd = PC
                            Seletor_Ula <= 3'd0;        //Operação carregar A
                            mux_A_seletor <= 3'd0;      //Endereço contido em PC sai do MUX de cima
                            Mux_Banco_Reg_Seletor <= 0; //O resultado da operação(ALU_OUT) vai para datain no banco de registradores
                            bancoRegisters_wr <= 1;     //Permitirá ao banco de registradores escrever o resultado(datain) da operação em rd
                            //PC = PC + imm[20:1][0]*2
                            Seletor_Ula <= 3'd1;        //Operação soma
                            mux_A_seletor <= 3'd0;      //Endereço contido em PC sai do MUX de cima
                            mux_B_seletor <= 3'd3;      //Endereço contido em immediate sai do MUX de baixo
                        end           
                    endcase
                    estado <= estado.first;      
                end            
            
            //default: begin

                //end
                default :begin
                    PC_Write <= 1;
                    Seletor_Ula <= 3'd1;
                    mux_A_seletor <= 3'd3;
                    mux_B_seletor <= 3'd3;
                end
            endcase
            //estado = estado.next;
        end
    end
endmodule