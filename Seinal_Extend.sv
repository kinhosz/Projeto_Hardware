module Sinal_Extend(
            input logic [31:0] Sinal_In,
            output logic [64-1:0] Sinal_Out
        );

always_comb begin

	Sinal_Out = { Sinal_In, 32'd0};
  
	
    end
endmodule 
