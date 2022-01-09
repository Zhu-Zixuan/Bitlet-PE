/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Prim_BufferArray
 * Discription: Buffer array model used in Bitlet PE.
 * Dependency:  Bitlet_Prime_Decoder.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

module Bitlet_Prim_BufferArray
#(
    parameter   N   = 4,                // number of data
    parameter   W   = 16                // width of data
)
(
    input                   clk,
    input                   rst_n,
    input                   enw,        // active high, 1 cycle
    input   [$clog2(N)-1:0] sel,
    input   [1*W-1:0]       DI,
    output  [N*W-1:0]       DO
);

wire    [N-1:0]     sel_dec;
wire    [N-1:0]     enw_dec;

Bitlet_Prim_Decoder_Decimal_to_Onehot #(.W(N)) UDECODER
(
    .DI(sel),
    .DO(sel_dec)
);

generate
    genvar g;
    for (g=0; g<N; g=g+1)
    begin
        assign  enw_dec[g]  = enw&sel_dec[g];
    end
    for (g=0; g<N; g=g+1)
    begin
        Bitlet_Prim_Buffer #(.W(W)) UBUFFER
        (
            .clk(clk),
            .rst_n(rst_n),
            .enw(enw_dec[g]),
            .DI(DI),
            .DO(DO[(g*W)+:W])
        );
    end
endgenerate

endmodule

module Bitlet_Prim_Buffer
#(
    parameter   W = 16                  // width of data
)
(
    input               clk,
    input               rst_n,
    input               enw,            // active high, 1 cycle
    input       [W-1:0] DI,
    output reg  [W-1:0] DO
);

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        DO  <= 'b0;
    else if (enw)
        DO  <= DI;
end

endmodule
