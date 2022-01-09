/*
 * Project:     Bitlet PE
 * Module:      Bitlet_ReassemblerArray
 * Discription: Reassembler in preprocessor of Bitlet PE, to reassemble A.bin in float or fixed point into an unified format where E.sum and A.fix contain all information in W and A.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_ReassemblerArray
#(
    parameter   N_input = 16
)
(
    input                           isfix,      // active high, stable
    input   [N_input*1-1:0]         Wsig_vec,
    input   [N_input*`Wid_exp-1:0]  Wexp_vec,
    input   [N_input*`Wid_bin-1:0]  Abin_vec,
    output  [N_input*`Wid_exs-1:0]  Esum_vec,
    output  [N_input*`Wid_fix-1:0]  Afix_vec
);

generate
    genvar g;
    for (g=0; g<N_input; g=g+1)
    begin
        Bitlet_Reassembler UDEASSEMBLER
        (
            .isfix(isfix),
            .Wsig(Wsig_vec[(g*1)+:1]),
            .Wexp(Wexp_vec[(g*`Wid_exp)+:`Wid_exp]),
            .Abin(Abin_vec[(g*`Wid_bin)+:`Wid_bin]),
            .Esum(Esum_vec[(g*`Wid_exs)+:`Wid_exs]),
            .Afix(Afix_vec[(g*`Wid_fix)+:`Wid_fix])
        );
    end
endgenerate

endmodule

module Bitlet_Reassembler
(
    input                   isfix,
    input                   Wsig,
    input   [`Wid_exp-1:0]  Wexp,
    input   [`Wid_bin-1:0]  Abin,
    output  [`Wid_exs-1:0]  Esum,
    output  [`Wid_fix-1:0]  Afix
);

wire                    Asig;
wire    [`Wid_exp-1:0]  Aexp;
wire    [`Wid_abs-1:0]  Aman;

Bitlet_Unpack UUNPACK
(
    .bin(Abin),
    .isfix(isfix),
    .sig(Asig),
    .exp(Aexp),
    .man(Aman)
);

reg     [`Wid_fix-1:0]  tmp_fix;

assign  Esum    = Wexp + Aexp;
assign  Afix    = tmp_fix;

always @(*)
begin
    if (isfix)  tmp_fix = (Wsig) ? (~{Asig, Aman}+1) : {Asig, Aman};
    else        tmp_fix = (Wsig^Asig) ? (~{1'b0, Aman}+1) : {1'b0, Aman};
end

endmodule

module Bitlet_Unpack
(
    input   [`Wid_bin-1:0]  bin,
    input                   isfix,
    output                  sig,
    output  [`Wid_exp-1:0]  exp,
    output  [`Wid_abs-1:0]  man
);

assign sig      = bin[`Wid_bin-1];
assign exp      = ((~|bin[`Wid_man+:`Wid_exp])&(|bin[0+:`Wid_man])) ? 'b1 : bin[`Wid_man+:`Wid_exp];
assign man      = (isfix) ? bin[0+:`Wid_abs] : {|exp, bin[0+:`Wid_man]};

endmodule
