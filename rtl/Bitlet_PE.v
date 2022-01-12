/*
 * Project:     Bitlet PE
 * Module:      Bitlet_PE
 * Discription: Bitlet PE top module.
 * Dependency:  Bitlet_Processor.v Bitlet_Calculator.v Bitlet_Postprocessor.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_PE
#(
    parameter   N_total = 64,
    parameter   N_input = 16
)
(
    input                               clk,
    input                               rst_n,
    input                               isfix,      // active high, stable
    input                               relu,       // active high, stable
    input   [`Wid_quant-1:0]            quant,      // quantization, 24~0, SPI
    input   [`Max_quant-1:0]            prune,      // prunning width, 24~0, SPI
    input                               flush,      // active high, 1 cycle
    input   [N_total*1-1:0]             Wsig_vec,
    input   [N_total*`Wid_exp-1:0]      Wexp_vec,
    input   [N_total*`Wid_abs-1:0]      Wabs_vec,
    input                               Abin_vld,   // active high, 1 cycle
    input   [N_input*`Wid_bin-1:0]      Abin_vec,
    output                              res_vld,    // active high, 1 cycle
    output  [`Wid_bin-1:0]              res
);

wire                            Emax_vld;
wire    [`Wid_exs-1:0]          Emax;
wire                            Wabs_vld;
wire    [N_total*`Wid_fix-1:0]  Afix_buff;
wire    [N_total*`Wid_abs-1:0]  Wabs_buff;
wire                            Aacc_vld;
wire    [`Wid_acc-1:0]          Aacc;

Bitlet_Preprocessor #(.N_total(N_total), .N_input(N_input)) UPREPROCESSOR
(
    .clk(clk),
    .rst_n(rst_n),
    .isfix(isfix),
    .flush(flush),
    .Wsig_vec(Wsig_vec),
    .Wexp_vec(Wexp_vec),
    .Wabs_vec(Wabs_vec),
    .Abin_vld(Abin_vld),
    .Abin_vec(Abin_vec),
    .Emax_vld(Emax_vld),
    .Emax(Emax),
    .finish(Wabs_vld),
    .Afix_buff(Afix_buff),
    .Wabs_buff(Wabs_buff)
);

Bitlet_Calculator #(.N_total(N_total)) UCALCULATOR
(
    .clk(clk),
    .rst_n(rst_n),
    .prune(prune),
    .flush(flush),
    .Wabs_vld(Wabs_vld),
    .Wabs_vec(Wabs_buff),
    .Afix_vec(Afix_buff),
    .Aacc_vld(Aacc_vld),
    .Aacc(Aacc)
);

Bitlet_Postprocessor UPOSTPROCESSOR
(
    .clk(clk),
    .rst_n(rst_n),
    .isfix(isfix),
    .relu(relu),
    .quant(quant),
    .Aacc_vld(Aacc_vld),
    .Aacc(Aacc),
    .Emax_vld(Emax_vld),
    .Emax(Emax),
    .res_vld(res_vld),
    .res(res)
);

endmodule