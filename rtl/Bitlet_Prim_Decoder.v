/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Prim_Decoder_Decimal_to_Onehot
 * Discription: BCD code to one-hot code decoder.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

module Bitlet_Prim_Decoder_Decimal_to_Onehot
#(
    parameter   W   = 16        // width of output
)
(
    input   [$clog2(W)-1:0] DI,
    output  [W-1:0]         DO
);

assign  DO  = 'b1 << DI;

endmodule
