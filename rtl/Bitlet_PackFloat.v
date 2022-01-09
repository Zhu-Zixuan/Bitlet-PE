/*
 * Project:     Bitlet PE
 * Module:      Bitlet_PackFloat
 * Discription: IEEE float32 packager, to pack result into standard IEEE-754 float32 single precision format.
 * Dependency:  
 *
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_PackFloat
(
    input                       clk,
    input                       rst_n,
    input                       Aacc_vld,
    input       [`Wid_acc-1:0]  Aacc,
    input                       Emax_vld,
    input       [`Wid_exs-1:0]  Emax,
    output reg                  res_vld,
    output reg  [`Wid_bin-1:0]  res
);

integer i;

localparam  Wid_cnt = $clog2(`Wid_acc);

wire    Aacc_sig;
assign  Aacc_sig    = Aacc[`Wid_acc-1];

/* ----------------- calculate final Emax with correct bias ----------------- */
reg     [`Wid_exs:0]  Emax_correct;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Emax_correct    <= 'b0;
    else if (Emax_vld)
        Emax_correct    <= $signed({1'b0, Emax}) - `Const_bias - `Const_frac;
end

/* --------------- pack float point step 1: calculate acc_abs --------------- */
reg     [`Wid_acc-1:0]  Aacc_abs;
reg                     abs_vld;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Aacc_abs <= 'b0;
    else if (Aacc_vld)
        Aacc_abs <= (Aacc_sig) ? (~Aacc+1) : Aacc;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        abs_vld <= 1'b0;
    else if (abs_vld!=Aacc_vld)
        abs_vld <= Aacc_vld;
end

/* -------------------- pack float point step 2: findMSB -------------------- */
wire                    tmp_zero;
wire    [Wid_cnt-1:0]   tmp_cnt;
reg                     zero;
reg     [Wid_cnt-1:0]   cnt;
reg                     cnt_vld;

Bitlet_FindMSB #(.W(`Wid_acc)) UFINDMSB
(
    .DI(Aacc_abs),
    .zero(tmp_zero),
    .cnt(tmp_cnt)
);

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        zero    <= 'b0;
        cnt     <= 'b0;
    end
    else if (abs_vld)
    begin
        zero    <= tmp_zero;
        cnt     <= tmp_cnt;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        cnt_vld <= 'b0;
    else if (cnt_vld!=abs_vld)
        cnt_vld <= abs_vld;
end

/* ----------------- pack float point step 3: normalization ----------------- */
wire    [`Wid_exs:0]    tmp_exp_norm;
wire    [`Wid_abs-1:0]  tmp_abs_norm;
reg     [`Wid_exp-1:0]  exp_norm;
reg     [`Wid_exs:0]    abs_sa;
reg     [`Wid_abs-1:0]  abs_norm;
reg                     fp_inf;
reg                     norm_vld;

assign  tmp_exp_norm    = $signed(Emax_correct) + cnt;
assign  tmp_abs_norm    = {Aacc_abs, `Wid_man'b0} >> cnt;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        exp_norm    <= 'b0;
        abs_sa      <= 'b0;
        abs_norm    <= 'b0;
        fp_inf      <= 'b0;
    end
    else if (cnt_vld)
    begin
        exp_norm    <= (($signed(tmp_exp_norm)<`Const_emin)||zero) ? 'b0 : tmp_exp_norm[0+:`Wid_exp];
        abs_sa      <= (($signed(tmp_exp_norm)<`Const_emin)&&!zero) ? (1-$signed(tmp_exp_norm)) : 'b0;
        abs_norm    <= (zero) ? 'b0 : tmp_abs_norm[0+:`Wid_abs];
        fp_inf      <= (($signed(tmp_exp_norm)>`Const_emax)&&(!zero)) ? 1'b1 : 1'b0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        norm_vld    <= 1'b0;
    else if (norm_vld!=cnt_vld)
        norm_vld    <= cnt_vld;
end

/* ------------------- pack float point step 4: exception ------------------- */
wire    [`Wid_abs-1:0]  tmp_final_abs;
reg     [`Wid_man-1:0]  final_man;
reg     [`Wid_exp-1:0]  final_exp;

assign  tmp_final_abs   = abs_norm >> abs_sa;

always @(*)
begin
    final_man       = (zero|fp_inf) ? 'b0 : tmp_final_abs[0+:`Wid_man];
    final_exp       = (fp_inf) ? (`Const_emax+1) : exp_norm;
end

/* ---------------------------- pack float point ---------------------------- */
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        res <= 'b0;
    else if (norm_vld)
        res <= {Aacc_sig, final_exp, final_man};
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        res_vld <= 1'b0;
    else if (res_vld!=norm_vld)
        res_vld <= norm_vld;
end

endmodule


