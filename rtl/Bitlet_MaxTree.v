/*
 * Project:     Bitlet PE
 * Module:      Bitlet_MaxTree
 * Discription: Compare tree, to find out maximum value among DI in pipeline.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

module Bitlet_MaxTree
#(
    parameter N = 16,   // number of input
    parameter W = 9     // width of input
)
(
    input               clk,
    input               rst_n,
    input               DI_vld,     // active high, 1 cycle
    input   [N*W-1:0]   DI_vec,     // input as a vector
    output              MAX_vld,    // active high, 1 cycle
    output  [W-1:0]     MAX
);

localparam  D   = $clog2(N);        // depth of compare tree

integer i, j;

reg             pmax_vld[D:0];
reg     [W-1:0] pmax_reg[D:0][N-1:0];
wire    [W-1:0] pmax_res[D:0][N-1:0];

assign  MAX_vld = pmax_vld[0];
assign  MAX     = pmax_reg[0][0];
genvar g, k;

always @(*)
begin
    pmax_vld[D]   = DI_vld;
end
for (g=0; g<D; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            pmax_vld[g] <= 1'b0;
        else if (pmax_vld[g]!=pmax_vld[g+1])
            pmax_vld[g] <= pmax_vld[g+1];
    end
end
always @(*)
begin
    for (i=0; i<N; i=i+1)
    begin
        pmax_reg[D][i]   = DI_vec[(i*W)+:W];
    end
end

for (g=0; g<D; g=g+1)
begin
    for (k=0; k<2**g; k=k+1)
    begin
        always @(posedge clk or negedge rst_n)
        begin
            if (!rst_n)
                pmax_reg[g][k]  <= 'b0;
            else if (pmax_vld[g+1])
                pmax_reg[g][k]  <=  pmax_res[g][k];
        end
    end
end
generate
    for (g=0; g<D; g=g+1)
    begin
        for (k=0; k<2**g; k=k+1)
        begin
            FindMax #(.W(W)) UFINDMAX
            (
                .I1(pmax_reg[g+1][2*k+1]),
                .I0(pmax_reg[g+1][2*k+0]),
                .O(pmax_res[g][k])
            );
        end
    end
endgenerate

endmodule


module FindMax
#(
    parameter W = 9
)
(
    input   [W-1:0] I1,
    input   [W-1:0] I0,
    output  [W-1:0] O
);

assign O = (I1<I0) ? I0 : I1;

endmodule
