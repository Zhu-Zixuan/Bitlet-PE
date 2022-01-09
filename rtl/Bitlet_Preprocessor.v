/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Preprocessor
 * Discription: Bitlet preprocessor, to reassemble input data and align W.abs.
 * Dependency:  Bitlet_Aligner.v Bitlet_FindMax.v Bitlet_Reassembler.v Bitlet_Prim_Buffer.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_Preprocessor
#(
    parameter   N_total = 64,
    parameter   N_input = 16
)
(
    input                           clk,
    input                           rst_n,
    input                           isfix,      // active high, stable
    input                           flush,      // active high, 1 cycle
    input   [N_total*1-1:0]         Wsig_vec,
    input   [N_total*`Wid_exp-1:0]  Wexp_vec,
    input   [N_total*`Wid_abs-1:0]  Wabs_vec,
    input                           Abin_vld,
    input   [N_input*`Wid_bin-1:0]  Abin_vec,
    output                          Emax_vld,   // active high, 1 cycle
    output  [`Wid_exs-1:0]          Emax,
    output                          finish,     // active high, 1 cycle
    output  [N_total*`Wid_fix-1:0]  Afix_buff,
    output  [N_total*`Wid_abs-1:0]  Wabs_buff
);

localparam  P_input = N_total/N_input;
localparam  N_align = `N_check;
localparam  P_align = N_total/N_align;

/* ---------------------------- input controller ---------------------------- */
reg     [$clog2(P_input)-1:0]   input_cnt;              // input counter

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        input_cnt   <= 'b0;
    else if (Abin_vld)
        input_cnt   <= input_cnt+1;
end

/* ---------------------- reassembler array for A.bin ----------------------- */
wire    [N_input*`Wid_exs-1:0]  Esum_dasm;
wire    [N_input*`Wid_fix-1:0]  Afix_dasm;
wire    [N_input*1-1:0]         Wsig_sel;
wire    [N_input*`Wid_exp-1:0]  Wexp_sel;
reg                             dasm_vld;

assign  Wsig_sel    = Wsig_vec[(input_cnt*N_input*1)+:(N_input*1)];
assign  Wexp_sel    = Wexp_vec[(input_cnt*N_input*`Wid_exp)+:(N_input*`Wid_exp)];

always @(*)
begin
    dasm_vld    = Abin_vld;
end

Bitlet_ReassemblerArray #(.N_input(N_input)) UDEASSEMBLERARRAY
(
    .isfix(isfix),
    .Wsig_vec(Wsig_sel),
    .Wexp_vec(Wexp_sel),
    .Abin_vec(Abin_vec),
    .Esum_vec(Esum_dasm),
    .Afix_vec(Afix_dasm)
);

/* ------------------- local buffer for deassembled E.sum ------------------- */
wire    [N_total*`Wid_exs-1:0]  Esum_buff;
reg                             Esum_enw;
reg                             Esum_vld;

always @(*)
begin
    Esum_enw    = (!isfix)&dasm_vld;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Esum_vld    <= 'b0;
    else if (Emax_vld!=dasm_vld)
        Esum_vld    <= dasm_vld;
end

Bitlet_Prim_BufferArray #(.N(P_input), .W(N_input*`Wid_exs)) UBUFFERESUM
(
    .clk(clk),
    .rst_n(rst_n),
    .enw(Esum_enw),
    .sel(input_cnt),
    .DI(Esum_dasm),
    .DO(Esum_buff)
);

/* ------------------- local buffer for deassembled A.fix ------------------- */
reg                             Afix_enw;

always @(*)
begin
    Afix_enw    = dasm_vld;
end

Bitlet_Prim_BufferArray #(.N(P_input), .W(N_input*`Wid_fix)) UBUFFERAFIX
(
    .clk(clk),
    .rst_n(rst_n),
    .enw(Afix_enw),
    .sel(input_cnt),
    .DI(Afix_dasm),
    .DO(Afix_buff)
);

/* ------------------------------- find E.max ------------------------------- */
reg     [$clog2(P_input)-1:0]   ckmax_cnt;
wire    [N_input*`Wid_exs-1:0]  Esum_check;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        ckmax_cnt   <= 'b0;
    else if (ckmax_cnt!=input_cnt)
        ckmax_cnt   <= input_cnt;
end

assign  Esum_check  = Esum_buff[(ckmax_cnt*N_input*`Wid_exs)+:(N_input*`Wid_exs)];

Bitlet_FindMax #(.N_input(N_input), .P_input(P_input)) UFINDMAX
(
    .clk(clk),
    .rst_n(rst_n),
    .flush(flush),
    .Esum_vld(Esum_vld),
    .Esum_vec(Esum_check),
    .Emax_vld(Emax_vld),
    .Emax(Emax)
);

/* ---------------------------- align some W.abs ---------------------------- */
wire    [N_align*`Wid_abs-1:0]  Wabs_sel;
wire    [N_align*`Wid_exs-1:0]  Esum_align;
wire    [N_align*`Wid_abs-1:0]  Walign_vec;
reg     [$clog2(P_align)-1:0]   align_cnt;
reg                             align_vld;

assign  Wabs_sel    = Wabs_vec[(align_cnt*N_align*`Wid_abs)+:(N_align*`Wid_abs)];
assign  Esum_align  = Esum_buff[(align_cnt*N_align*`Wid_exs)+:(N_align*`Wid_exs)];

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        align_cnt   <= 'b0;
    else if (flush)
        align_cnt   <= 'b0;
    else if (align_vld)
        align_cnt   <= align_cnt + 1;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        align_vld   <= 1'b0;
    else if (flush)
        align_vld   <= 1'b0;
    else if (Emax_vld)
        align_vld   <= 1'b1;
    else if (align_cnt==P_align-1)
        align_vld   <= 1'b0;
end

Bitlet_AlignerArray #(.N_align(N_align)) UALIGNERARRAY
(
    .Wabs_vec(Wabs_sel),
    .Esum_vec(Esum_align),
    .Emax(Emax),
    .Walign_vec(Walign_vec)
);

/* --------------------- local buffer for aligned W.abs --------------------- */
reg                             Wabs_enw;
reg                             Wabs_vld;

always @(*)
begin
    Wabs_enw    = align_vld;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Wabs_vld    <= 1'b0;
    else if (Wabs_vld!=align_vld)
        Wabs_vld    <= align_vld;
end

Bitlet_Prim_BufferArray #(.N(P_align), .W(N_align*`Wid_abs)) UBUFFERWABS
(
    .clk(clk),
    .rst_n(rst_n),
    .enw(Wabs_enw),
    .sel(align_cnt),
    .DI(Walign_vec),
    .DO(Wabs_buff)
);

/* ------------------------- preprocess finish flag ------------------------- */
assign  finish  = Wabs_vld;

endmodule
