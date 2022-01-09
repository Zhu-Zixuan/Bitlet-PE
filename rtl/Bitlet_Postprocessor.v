/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Postprocessor
 * Discription: Postprocessor, to pack result into appointed format and operate ReLu activation function.
 * Dependency:  Bitlet_PackFloat.v Bitlet_PackFixed.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_Postprocessor
(
    input                           clk,
    input                           rst_n,
    input                           isfix,      // active high, stable
    input                           relu,       // active high, stable
    input       [`Wid_quant-1:0]    quant,
    input                           Aacc_vld,   // active high, 1 cycle
    input       [`Wid_acc-1:0]      Aacc,
    input                           Emax_vld,   // active high, 1 cycle
    input       [`Wid_exs-1:0]      Emax,
    output reg                      res_vld,    // active high, 1 cycle
    output reg  [`Wid_bin-1:0]      res
);

wire                    res_float_vld;
wire    [`Wid_bin-1:0]  res_float;
wire                    res_fixed_vld;
wire    [`Wid_bin-1:0]  res_fixed;
wire                    Aacc_sig;

assign  Aacc_sig    = Aacc[`Wid_acc-1];

Bitlet_PackFloat UPACKFLOAT
(
    .clk(clk),
    .rst_n(rst_n),
    .Aacc_vld(Aacc_vld),
    .Aacc(Aacc),
    .Emax_vld(Emax_vld),
    .Emax(Emax),
    .res_vld(res_float_vld),
    .res(res_float)
);

Bitlet_PackFixed UPACKFIXED
(
    .clk(clk),
    .rst_n(rst_n),
    .quant(quant),
    .Aacc_vld(Aacc_vld),
    .Aacc(Aacc),
    .res_vld(res_fixed_vld),
    .res(res_fixed)
);

always @(*)
begin
    res_vld = (isfix) ? res_fixed_vld : res_float_vld;
    res     = (isfix) ? res_fixed : res_float;
end

endmodule
