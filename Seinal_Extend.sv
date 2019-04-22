module Sinal_Extend(
            input logic [31:0] Sinal_In,
            output logic [64-1:0] Sinal_Out
        );

    always_comb begin

        if(Sinal_In[6:0]==7'd3) begin//tipo I
            if(Sinal_In[14:12]==3'd4 || Sinal_In[14:12]==3'd5 || Sinal_In[14:12]==3'd6) begin //lbu, lhu, lwu(extensão unsigned)
                Sinal_Out = { 52'd0, Sinal_In[31:20] };
            end
            else begin
                if(Sinal_In[14:12]==3'd0 || Sinal_In[14:12]==3'd2) begin //ld, lb, lh, lw(extensão signed)
                    if(Sinal_In[31]==0) begin
                        Sinal_Out = { 52'd0, Sinal_In[31:20] };
                    end
                    else begin
                        Sinal_Out = { 52'd1, Sinal_In[31:20] };
                    end    
                end
            end     
        end
        else begin
            if(Sinal_In[6:0]==7'd19) begin
                if(Sinal_In[14:12]==3'd0 || Sinal_In[14:12]==3'd2) begin //addi, slti(extensão signed)
                    if(Sinal_In[31]==0) begin
                        Sinal_Out = { 52'd0, Sinal_In[31:20] };
                    end
                    else begin
                        Sinal_Out = { 52'd1, Sinal_In[31:20] };
                    end    
                end
            end
            else begin
                if(Sinal_In[6:0]==7'd35) begin //tipo S(extensão signed)
                    if(Sinal_In[31]==0) begin
                        Sinal_Out = { 52'd0, Sinal_In[31:25], Sinal_In[11:7] };
                    end
                    else begin
                        if(Sinal_In[31]==1) begin
                            Sinal_Out = { 52'd1, Sinal_In[31:25], Sinal_In[11:7] };
                        end
                    end    
                end
            end            
        end

    end

endmodule 
