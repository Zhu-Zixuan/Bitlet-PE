/*
 * Project:     Bitlet PE
 * Module:      Bitlet_CheckWindow
 * Discription: Core module for Bitlet algorithm, to search for 1s in aligned W.abs and provide their index one per cycle.
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC) & LI Cheng-Long (UESTC), 2021.02
 */

`timescale 1ns / 1ps

`include "Bitlet_Defs.vh"

module Bitlet_CheckWindow
#(
    parameter N_total = 64
)
(
    input                               clk,
    input                               rst_n,
    input       [$clog2(N_total)-1:0]   N_calculate,// Number of inputs to calculate,-1
    input                               flush,      // active high, 1 cycle
    input                               en,         // active high, 1 cycle
    input       [N_total-1:0]           Wtrans,
    output reg                          sel_vld,    // active high, 1 cycle
    output reg                          zero,
    output reg  [$clog2(N_total)-1:0]   sel
);

localparam  Wid_sel = $clog2(N_total);

localparam  idle    = 2'b00;
localparam  working = 2'b01;
localparam  finish  = 2'b11;

(* fsm_state *)
reg     [1:0]   statec, staten;

wire    [N_total+`N_check-1:0]  Wext;
wire    [`N_check-1:0]          Wchk;
reg     [Wid_sel-1:0]           ptrc;
wire    [Wid_sel-0:0]           ptrn;
reg     [$clog2(`N_check)-1:0]  sel_devi, ptr_devi;

assign  Wext   = {{`N_check{1'b0}}, Wtrans};
assign  Wchk   = Wext[ptrc+:`N_check];
assign  ptrn    = ptrc + ptr_devi + 1'b1;

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        statec  <= idle;
    else if (flush)
        statec  <= idle;
    else
        statec  <= staten;
end

always @(*)
begin
    case (statec)
    idle:       staten  = (en) ? working : idle;
    working:    staten  = (ptrn>N_calculate) ? finish : working;
    finish:     staten  = finish;
    default:    staten  = idle;
    endcase
end


always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        ptrc    <= 'b0;
        sel     <= 'b0;
        zero    <= 1'b1;
        sel_vld <= 1'b0;
    end
    else
        case (statec)
        idle:
        begin
            if (ptrc!='b0)      ptrc    <= 'b0;
            if (sel_vld!=1'b0)  sel_vld <= 1'b0;
        end
        working:
        begin
            ptrc    <=  ptrn;
            sel     <= ptrc + sel_devi;
            zero    <= ~|(Wchk);
            if (sel_vld!=1'b1)  sel_vld <= 1'b1;
        end
        finish:
        begin
            if (sel_vld!=1'b0)  sel_vld <= 1'b0;
            if (flush)          ptrc    <= 'b0;
        end
        endcase
end

always @(*)
begin
    casex (Wchk)
    8'b00000000:    begin   sel_devi = 3'dx;    ptr_devi = 3'd7;    end

    8'b00000001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd7;    end
    8'b00000010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd7;    end
    8'b00000100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd7;    end
    8'b00001000:    begin   sel_devi = 3'd3;    ptr_devi = 3'd7;    end
    8'b00010000:    begin   sel_devi = 3'd4;    ptr_devi = 3'd7;    end
    8'b00100000:    begin   sel_devi = 3'd5;    ptr_devi = 3'd7;    end
    8'b01000000:    begin   sel_devi = 3'd6;    ptr_devi = 3'd7;    end
    8'b10000000:    begin   sel_devi = 3'd7;    ptr_devi = 3'd7;    end

    8'bxxxxxx11:    begin   sel_devi = 3'd0;    ptr_devi = 3'd0;    end
    8'bxxxxx101:    begin   sel_devi = 3'd0;    ptr_devi = 3'd1;    end
    8'bxxxx1001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd2;    end
    8'bxxx10001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd3;    end
    8'bxx100001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd4;    end
    8'bx1000001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd5;    end
    8'b10000001:    begin   sel_devi = 3'd0;    ptr_devi = 3'd6;    end

    8'bxxxxx110:    begin   sel_devi = 3'd1;    ptr_devi = 3'd1;    end
    8'bxxxx1010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd2;    end
    8'bxxx10010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd3;    end
    8'bxx100010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd4;    end
    8'bx1000010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd5;    end
    8'b10000010:    begin   sel_devi = 3'd1;    ptr_devi = 3'd6;    end

    8'bxxxx1100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd2;    end
    8'bxxx10100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd3;    end
    8'bxx100100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd4;    end
    8'bx1000100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd5;    end
    8'b10000100:    begin   sel_devi = 3'd2;    ptr_devi = 3'd6;    end

    8'bxxx11000:    begin   sel_devi = 3'd3;    ptr_devi = 3'd3;    end
    8'bxx101000:    begin   sel_devi = 3'd3;    ptr_devi = 3'd4;    end
    8'bx1001000:    begin   sel_devi = 3'd3;    ptr_devi = 3'd5;    end
    8'b10001000:    begin   sel_devi = 3'd3;    ptr_devi = 3'd6;    end

    8'bxx110000:    begin   sel_devi = 3'd4;    ptr_devi = 3'd4;    end
    8'bx1010000:    begin   sel_devi = 3'd4;    ptr_devi = 3'd5;    end
    8'b10010000:    begin   sel_devi = 3'd4;    ptr_devi = 3'd6;    end

    8'bx1100000:    begin   sel_devi = 3'd5;    ptr_devi = 3'd5;    end
    8'b10100000:    begin   sel_devi = 3'd5;    ptr_devi = 3'd6;    end

    8'b11000000:    begin   sel_devi = 3'd6;    ptr_devi = 3'd6;    end
    endcase
end

/*
always @(*)
begin
    (* full_case *)
    casex (Wchk)
    4'b0000:    begin   sel_devi = 2'dx;    ptr_devi = 2'd3;    end

    4'b0001:    begin   sel_devi = 2'd0;    ptr_devi = 2'd3;    end
    4'b0010:    begin   sel_devi = 2'd1;    ptr_devi = 2'd3;    end
    4'b0100:    begin   sel_devi = 2'd2;    ptr_devi = 2'd3;    end
    4'b1000:    begin   sel_devi = 2'd3;    ptr_devi = 2'd3;    end

    4'bxx11:    begin   sel_devi = 2'd0;    ptr_devi = 2'd0;    end
    4'bx101:    begin   sel_devi = 2'd0;    ptr_devi = 2'd1;    end
    4'b1001:    begin   sel_devi = 2'd0;    ptr_devi = 2'd2;    end

    4'bx110:    begin   sel_devi = 2'd1;    ptr_devi = 2'd1;    end
    4'b1010:    begin   sel_devi = 2'd1;    ptr_devi = 2'd2;    end

    4'b1100:    begin   sel_devi = 2'd2;    ptr_devi = 2'd2;    end
    endcase
end
*/

endmodule
