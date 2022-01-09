/*
 * Project:     Bitlet PE
 * Module:      Bitlet_PackFixed
 * Discription: Fixed point packager, to pack result into fixed point format according to quant signal.
 * Dependency:  
 *
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_PackFixed
(
    input                           clk,
    input                           rst_n,
    input       [`Wid_quant-1:0]    quant,
    input                           Aacc_vld,
    input       [`Wid_acc-1:0]      Aacc,
    output reg                      res_vld,
    output reg  [`Wid_bin-1:0]      res
);

wire    [`Max_quant:0]  illigal_sign_bit;
reg                     tmp_flow, tmp_overflow;
wire                    Aacc_sig;

assign  Aacc_sig    = Aacc[`Wid_acc-1];

generate
    genvar g;
    assign  illigal_sign_bit[`Max_quant]    = ^(Aacc[(`Wid_acc-1):(`Max_quant+`Wid_abs)]);
    for (g=0; g<`Max_quant; g=g+1)
        assign  illigal_sign_bit[g] = illigal_sign_bit[g+1] | (Aacc_sig ^ Aacc[g+`Wid_abs]);
endgenerate

always @(*)
begin
    tmp_flow                    = illigal_sign_bit[quant];
    tmp_overflow                = tmp_flow&(!Aacc_sig);
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        res <= 'b0;
    else if (Aacc_vld)
    begin
        res[`Wid_bin-1]     <= Aacc_sig;
        res[0+:`Wid_abs]    <= (tmp_flow) ? {`Wid_abs{tmp_overflow}} : Aacc[quant+:`Wid_abs];
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        res_vld <= 1'b0;
    else if (res_vld)
        res_vld <= 1'b0;
    else
        res_vld   <= Aacc_vld;
end

endmodule
