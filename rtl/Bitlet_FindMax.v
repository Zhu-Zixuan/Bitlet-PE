/*
 * Project:     Bitlet PE
 * Module:      Bitlet_FindMax
 * Discription: E.max calculation, to give maximum E.sum among all inputs.
 * Dependency:  Bitlet_MaxTree.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_FindMax
#(
    parameter   N_input = 16,
    parameter   P_input = 4
)
(
    input                               clk,
    input                               rst_n,
    input                               flush,
    input                               Esum_vld,
    input       [N_input*`Wid_exs-1:0]  Esum_vec,
    output reg                          Emax_vld,
    output reg  [`Wid_exs-1:0]          Emax
);

wire    [`Wid_exs-1:0]          pmax;
wire                            pmax_vld;
reg     [$clog2(P_input)-1:0]   max_cnt;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        max_cnt <= 'b0;
    else if (flush)
        max_cnt <= 'b0;
    else if (pmax_vld)
        max_cnt <= max_cnt+1;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Emax    <= 'b0;
    else if (flush)
        Emax    <= 'b0;
    else if (pmax_vld&&(pmax>Emax))
        Emax    <= pmax;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Emax_vld    <= 1'b0;
    else if (pmax_vld&&(max_cnt==(P_input-1)))
        Emax_vld    <= 1'b1;
    else if (Emax_vld)
        Emax_vld    <= 1'b0;
end

Bitlet_MaxTree #(.N(N_input), .W(`Wid_exs)) UMAXTREE
(
    .clk(clk),
    .rst_n(rst_n),
    .DI_vld(Esum_vld),
    .DI_vec(Esum_vec),
    .MAX_vld(pmax_vld),
    .MAX(pmax)
);

endmodule
