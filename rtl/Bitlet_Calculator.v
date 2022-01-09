/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Calculator
 * Discription: Bitlet PE calculator module.
 * Dependency:  Bitlet_CE.v Bitlet_Accumulator.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_Calculator
#(
    parameter   N_total = 64
)
(
    input                           clk,
    input                           rst_n,
    input   [$clog2(N_total)-1:0]   N_calculate,
    input   [`Max_quant-1:0]        prune,
    input                           flush,
    input                           Wabs_vld,
    input   [N_total*`Wid_abs-1:0]  Wabs_vec,
    input   [N_total*`Wid_fix-1:0]  Afix_vec,
    output                          Aacc_vld,
    output  [`Wid_acc-1:0]          Aacc
);

/* ---------------------------- Bitlet CE module ---------------------------- */
wire                                Asel_vld;
wire    [`N_channel*`Wid_fix-1:0]   Asel_vec;

Bitlet_CE #(.N_total(N_total)) UBCE
(
    .clk(clk),
    .rst_n(rst_n),
    .N_calculate(N_calculate),
    .prune(prune),
    .flush(flush),
    .Wabs_vld(Wabs_vld),
    .Wabs_vec(Wabs_vec),
    .Afix_vec(Afix_vec),
    .Asel_vld(Asel_vld),
    .Asel_vec(Asel_vec)
);

/* ----------------------- 24-input shift accumulator ----------------------- */
Bitlet_Accumulator UACCUMULATOR
(
    .clk(clk),
    .rst_n(rst_n),
    .flush(flush),
    .Asel_vld(Asel_vld),
    .Asel_vec(Asel_vec),
    .Aacc_vld(Aacc_vld),
    .Aacc(Aacc)
);

endmodule
