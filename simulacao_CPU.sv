module simulcao_CPU;
    logic clock;
    logic reset;
    logic [63:0]Ula_Out;


    CPU teste_CPU(      .clock(     clock           ),
                        .reset(     reset           ),
                        .ULA_Out(   Ula_Out         )
                                                    );
    localparam CLKPERIODO = 10000;
    localparam CLKDELAY = CLKPERIODO/2;
    initial begin
        clock = 1'b1;
        
        #(CLKPERIODO)
        #(CLKPERIODO)
        #(CLKPERIODO);
        //reset = 1'b1;
    end

    always #(CLKDELAY) clock = ~clock;

    always_ff@(posedge clock or posedge reset)begin
        $monitor($time," Saida da ULA = %d Clock :%b ",Ula_Out,clock);
    end
endmodule
