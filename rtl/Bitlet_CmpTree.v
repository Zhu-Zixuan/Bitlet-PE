/*
 * Project:     Bitlet PE
 * Module:      Bitlet_CmpTree
 * Discription: 24-input adder tree with inner shifting.
 * Dependency:  Bitlet_Prim_Compactor.v
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */
`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_CmpTree
(
    input                           clk,
    input                           rst_n,
    input                           DI_vld,
    input       [24*`Wid_fix-1:0]   DI_vec,
    output reg                      SUM_vld,
    output reg  [`Wid_sum-1:0]      SUM
);

integer i;
genvar  g;

/* --------------------------------- stage0 --------------------------------- */
reg     [`Wid_sum-1:0]  stage0_res[24-1:0];
reg                     stage0_vld;

always @(*)
begin
    for (i=0; i<24; i=i+1)
    begin
        stage0_res[i]   = $signed(DI_vec[(i*`Wid_fix)+:`Wid_fix]) << i;
    end
    stage0_vld  = DI_vld;
end

/* --------------------------------- stage1 --------------------------------- */
wire    [`Wid_sum-1:0]  stage1_out[12-1:0];
reg     [`Wid_sum-1:0]  stage1_res[12-1:0];
reg                     stage1_vld;
for (g=0; g<12; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            stage1_res[g]   <= 'b0;
        else if (stage0_vld)
            stage1_res[g]   <= stage1_out[g];
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        stage1_vld  <= 1'b0;
    else if (stage1_vld!=stage0_vld)
        stage1_vld  <= stage0_vld;
end

generate
    for (g=0; g<6; g=g+1)
    begin:g_Bitlet_Cmp4to2
        Bitlet_Cmp4to2 #(.W(`Wid_sum)) UCMPSTAGE1
        (
            .I3(stage0_res[g*4+3]),
            .I2(stage0_res[g*4+2]),
            .I1(stage0_res[g*4+1]),
            .I0(stage0_res[g*4+0]),
            .O1(stage1_out[g*2+1]),
            .O0(stage1_out[g*2+0])
        );
    end
endgenerate

/* --------------------------------- stage2 --------------------------------- */
wire    [`Wid_sum-1:0]  stage2_out[6-1:0];
reg     [`Wid_sum-1:0]  stage2_res[6-1:0];
reg                     stage2_vld;

for (g=0; g<6; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            stage2_res[g]   <= 'b0;
        else if (stage1_vld)
            stage2_res[g]   <= stage2_out[g];
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        stage2_vld  <= 1'b0;
    else if (stage2_vld!=stage1_vld)
        stage2_vld  <= stage1_vld;
end

generate
    for (g=0; g<3; g=g+1)
    begin
        Bitlet_Cmp4to2 #(.W(`Wid_sum)) UCMPSTAGE2
        (
            .I3(stage1_res[g*4+3]),
            .I2(stage1_res[g*4+2]),
            .I1(stage1_res[g*4+1]),
            .I0(stage1_res[g*4+0]),
            .O1(stage2_out[g*2+1]),
            .O0(stage2_out[g*2+0])
        );
    end
endgenerate

/* --------------------------------- stage3 --------------------------------- */
wire    [`Wid_sum-1:0]  stage3_out[4-1:0];
reg     [`Wid_sum-1:0]  stage3_res[4-1:0];
reg                     stage3_vld;
for (g=0; g<4; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            stage3_res[g]   <= 'b0;
        else if (stage2_vld)
            stage3_res[g]   <= stage3_out[g];
    end
end
always @(posedge clk or negedge rst_n)
begin
    if  (!rst_n)
        stage3_vld  <= 1'b0;
    else if (stage3_vld!=stage2_vld)
        stage3_vld  <= stage2_vld;
end

Bitlet_Cmp4to2 #(.W(`Wid_sum)) UCMPSTAGE3
(
    .I3(stage2_res[3]),
    .I2(stage2_res[2]),
    .I1(stage2_res[1]),
    .I0(stage2_res[0]),
    .O1(stage3_out[1]),
    .O0(stage3_out[0])
);

assign  stage3_out[2]   = stage2_res[4];
assign  stage3_out[3]   = stage2_res[5];

/* --------------------------------- stage4 --------------------------------- */
wire    [`Wid_sum-1:0]  stage4_out[2-1:0];
reg     [`Wid_sum-1:0]  stage4_res[2-1:0];
reg                     stage4_vld;
for (g=0; g<2; g=g+1)
begin
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
            stage4_res[g]   <= 'b0;
        else if (stage3_vld)
            stage4_res[g]   <= stage4_out[g];
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        stage4_vld  <= 1'b0;
    else if (stage4_vld!=stage3_vld)
        stage4_vld  <= stage3_vld;
end

Bitlet_Cmp4to2 #(.W(`Wid_sum)) UCMPSTAGE4
(
    .I3(stage3_res[3]),
    .I2(stage3_res[2]),
    .I1(stage3_res[1]),
    .I0(stage3_res[0]),
    .O1(stage4_out[1]),
    .O0(stage4_out[0])
);

/* --------------------------------- stage5 --------------------------------- */
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        SUM_vld <= 1'b0;
    else if (SUM_vld!=stage4_vld)
        SUM_vld <= stage4_vld;
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        SUM <= 'b0;
    else if (stage4_vld)
        SUM <= $signed(stage4_res[1]) + $signed(stage4_res[0]);
end

endmodule
