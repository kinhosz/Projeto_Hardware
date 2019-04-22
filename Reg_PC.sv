module Reg_PC(
            input clk,
            input reset,
            input regWrite,
            input logic [64-1:0] DadoIn,
            output logic [32-1:0] DadoOut
        );

always_ff @(posedge clk or posedge reset)
begin	
	if(reset)
		DadoOut <= 32'd0;
	else
	begin
		if (regWrite) begin
		    DadoOut <= DadoIn[31:0];
		end
	end		
end
endmodule 
