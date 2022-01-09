/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Accumulator
 * Discription: 24-input shift-accumulator.
 * Dependency:  Bitlet_CmpTree.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_Accumulator
(
    input                                   clk,
    input                                   rst_n,
    input                                   flush,
    input                                   Asel_vld,
    input       [`N_channel*`Wid_fix-1:0]   Asel_vec,
    output reg                              Aacc_vld,
    output reg  [`Wid_acc-1:0]              Aacc
);

wire                    psum_vld;
wire    [`Wid_sum-1:0]  psum;

reg                     working;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Aacc    <= 'b0;
    else if (flush)
        Aacc    <= 'b0;
    else if (psum_vld)
        Aacc    <= $signed(Aacc) + $signed(psum);
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        working <= 1'b0;
    else if (psum_vld&&(!working))
        working <= 1'b1;
    else if ((!psum_vld)&&working)
        working <= 1'b0;
end

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        Aacc_vld    <= 1'b0;
    else if ((!psum_vld)&&working)
        Aacc_vld    <= 1'b1;
    else if (Aacc_vld)
        Aacc_vld    <= 1'b0;
end

Bitlet_CmpTree UCCMPTREE
(
    .clk(clk),
    .rst_n(rst_n),
    .DI_vld(Asel_vld),
    .DI_vec(Asel_vec),
    .SUM_vld(psum_vld),
    .SUM(psum)
);

endmodule
