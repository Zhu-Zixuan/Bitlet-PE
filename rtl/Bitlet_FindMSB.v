/*
 * Project:     Bitlet PE
 * Module:      Bitlet_FindMSB
 * Discription: A component of packager, to locate MSB 1 in DI.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

module Bitlet_FindMSB
#(
    parameter W = 64
)
(
    input   [W-1:0]         DI,
    output                  zero,
    output  [$clog2(W)-1:0] cnt
);

localparam  N   = $clog2(W);

wire            or_tree[N:0][2**N-1:0];
wire    [N-1:0] pt_tree[N-1:0][2**(N-1)-1:0];

generate
    genvar i, j, k;
    for (j=0; j<2**N; j=j+1)
    begin
        assign or_tree[N][j]    = DI[j];
    end
    for (i=0; i<N; i=i+1)
    begin
        for (j=0; j<2**i; j=j+1)
        begin
            assign or_tree[i][j]    = or_tree[i+1][2*j+1] | or_tree[i+1][2*j+0];
        end
    end

    for (k=0; k<N; k=k+1)
    begin
        for (i=0; i<N-k-1; i=i+1)
        begin
            for (j=0; j<2**i; j=j+1)
            begin
                assign pt_tree[i][j][k] = (or_tree[i+1][2*j+1]) ? pt_tree[i+1][2*j+1][k] : pt_tree[i+1][2*j+0][k];
            end
        end
        for (j=0; j<2**(N-k-1); j=j+1)
        begin
            assign pt_tree[N-k-1][j][k] = or_tree[N-k][2*j+1];
        end
    end
endgenerate

//assign zero = ~|DI;
assign zero = ~or_tree[0][0];
assign cnt  = pt_tree[0][0];

endmodule
