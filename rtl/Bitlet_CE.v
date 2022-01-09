/*
 * Project:     Bitlet PE
 * Module:      Bitlet_CE
 * Discription: Bitlet Compute Engine, to give a group of selected A.fix and corresponding valid signal in each cycle.
 * Dependency:  Bitlet_CheckWindow.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_CE
#(
    parameter   N_total = 64
)
(
    input                                   clk,
    input                                   rst_n,
    input       [$clog2(N_total)-1:0]       N_calculate,// Number of inputs to calculate,-1
    input       [`Max_quant-1:0]            prune,
    input                                   flush,
    input                                   Wabs_vld,
    input       [N_total*`Wid_abs-1:0]      Wabs_vec,
    input       [N_total*`Wid_fix-1:0]      Afix_vec,
    output reg                              Asel_vld,
    output reg  [`N_channel*`Wid_fix-1:0]   Asel_vec
);

integer i;
genvar  g, k;

localparam  Wid_sel = $clog2(N_total);

/* ----------------------------- vector to net ------------------------------ */
wire    [`Wid_abs-1:0]      Wabs[N_total-1:0];
wire    [`Wid_fix-1:0]      Afix[N_total-1:0];

generate
    for (g=0; g<N_total; g=g+1)
    begin
        assign  Wabs[g] = Wabs_vec[(g*`Wid_abs)+:`Wid_abs];
        assign  Afix[g] = Afix_vec[(g*`Wid_fix)+:`Wid_fix];
    end
endgenerate

/* ---------------------------- transpose W.abs ----------------------------- */
wire    [N_total-1:0]       Wtrans[`N_channel-1:0];
wire                        Wtrans_vld;

assign  Wtrans_vld  = Wabs_vld;

generate
    for (g=0; g<`N_channel; g=g+1)
    begin
        for (k=0; k<N_total; k=k+1)
        begin
            assign  Wtrans[g][k]    = Wabs[k][g];
        end
    end
endgenerate

/* ------------------------------ check window ------------------------------ */
wire    [Wid_sel-1:0]       sel[`N_channel-1:0];
wire    [`N_channel-1:0]    sel_vld;
wire    [`N_channel-1:0]    sel_zero;

generate
    for (g=0; g<`N_channel; g=g+1)
    begin
        Bitlet_CheckWindow #(.N_total(N_total)) UCHECKWINDOW
        (
            .clk(clk),
            .rst_n(rst_n),
            .N_calculate(N_calculate),
            .flush(flush),
            .en(Wtrans_vld&prune[g]),
            .Wtrans(Wtrans[g]),
            .sel_vld(sel_vld[g]),
            .zero(sel_zero[g]),
            .sel(sel[g])
        );
    end
endgenerate

/* ------------------------------ select A.fix ------------------------------ */
reg     [`Wid_fix-1:0]      Asel[`N_channel-1:0];

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        Asel_vld    <= 1'b0;
    else if (flush)
        Asel_vld    <= 1'b0;
    else if (|sel_vld)
        Asel_vld    <= 1'b1;
    else if (Asel_vld)
        Asel_vld    <= 1'b0;
end
for (g=0; g<`N_channel; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            Asel[g] <= 'b0;
        else if (flush)
            Asel[g] <= 'b0;
        else if (sel_vld[g])
            Asel[g] <= (sel_zero[g]) ? 'b0 : Afix[sel[g]];
        else if ((!sel_vld[g])&&(Asel[g]!='b0))
            Asel[g] <= 'b0;
    end
end

/* ----------------------------- net to vector ------------------------------ */
always @(*)
begin
    for (i=0; i<`N_channel; i=i+1)
    begin
        Asel_vec[(i*`Wid_fix)+:`Wid_fix]    = Asel[i];
    end
end

endmodule
