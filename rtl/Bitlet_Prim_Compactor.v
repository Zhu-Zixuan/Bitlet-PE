/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Cmp4to2
 * Discription: Multi-bit 4 to 2 compactor
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

`timescale 1ns / 1ps

module Bitlet_Cmp4to2
#(
    parameter W = 16            // width of data
)
(
    input   [W-1:0] I3,
    input   [W-1:0] I2,
    input   [W-1:0] I1,
    input   [W-1:0] I0,
    output  [W-1:0] O1,
    output  [W-1:0] O0
);

wire    [W:0]   Cin;
wire    [W-1:0] Ctmp;

assign  Cin[0]  = 1'b0;
assign  O0      = Ctmp<<1;

generate
    genvar g;
    for (g=0; g<W; g=g+1)
    begin
        Bitlet_Compactor_4to2 UCOMPACTOR4TO2
        (
            .I3(I3[g]),
            .I2(I2[g]),
            .I1(I1[g]),
            .I0(I0[g]),
            .Cin(Cin[g]),
            .S(O1[g]),
            .C(Ctmp[g]),
            .Cout(Cin[g+1])
        );
    end
endgenerate

endmodule


module Bitlet_Compactor_4to2
(
    input   Cin,
    input   I3, I2, I1, I0,
    output  Cout,
    output  C,  S
);

wire    m0, m1, m2;

assign  m0      = I0 ^ I1;
assign  m1      = I2 ^ I3;
assign  m2      = m0 ^ m1;
assign  Cout    = (m1) ? I1 : I3;
assign  C       = (m2) ? Cin : I0;
assign  S       = Cin ^ m2;

endmodule

/*
module Bitlet_Compactor_3to2
(
    input   I2, I1, I0,
    output  C,  S
);

wire    m0;

assign  m0   = I0 ^ I1;
assign  C    = (m0) ? I2 : I1;
assign  S    = I2 ^ m0;

endmodule
*/
