/*
 * Project:     Bitlet PE
 * Module:      Bitlet_AlignerArray
 * Discription: Aligner for W.abs according to Emax and corresponding Esum.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_AlignerArray
#(
    parameter   N_align = 8
)
(
    input   [N_align*`Wid_abs-1:0]  Wabs_vec,
    input   [N_align*`Wid_exs-1:0]  Esum_vec,
    input   [`Wid_exs-1:0]          Emax,
    output  [N_align*`Wid_abs-1:0]  Walign_vec
);

generate
    genvar g;
    for (g=0; g<N_align; g=g+1)
    begin
        Bitlet_Aligner UALIGNER
        (
            .Wabs(Wabs_vec[(g*`Wid_abs)+:`Wid_abs]),
            .Esum(Esum_vec[(g*`Wid_exs)+:`Wid_exs]),
            .Emax(Emax),
            .Walign(Walign_vec[(g*`Wid_abs)+:`Wid_abs])
        );
    end
endgenerate

endmodule


module Bitlet_Aligner
(
    input   [`Wid_abs-1:0]  Wabs,
    input   [`Wid_exs-1:0]  Esum,
    input   [`Wid_exs-1:0]  Emax,
    output  [`Wid_abs-1:0]  Walign
);

wire    [`Wid_exs-1:0]  Ediff;

assign Ediff    = Emax - Esum;
assign Walign   = Wabs >> Ediff;

endmodule
