/*
 * Project:     Bitlet PE
 * Module:      Bitlet_Defs
 * Discription: Bitlet PE const define
 * Dependency:  
 * 
 * Author:      ZHU Zi-Xuan (UESTC), 2021.02
 */

/* This file defines the configuration parameters of Bitlet PE */

/* configuration */
`define Conf_float          1'b0
`define Conf_fixed          1'b1

/* constant */
`define Const_bias          127
`define Const_frac          46
`define Const_emax          254
`define Const_emin          0

/*  */
`define Wid_exp             8
`define Wid_man             23
`define Wid_bin             (`Wid_man+`Wid_exp+1)
`define Wid_exs             (`Wid_exp+1)
`define Wid_abs             (`Wid_man+1)
`define Wid_fix             (`Wid_abs+1)
`define Wid_sum             52
`define Wid_acc             64

`define N_channel           24
`define N_check             8
`define N_align             8

`define Max_quant           `Wid_abs
`define Wid_quant           $clog2(`Max_quant)


/* --------------------------------- ! Note --------------------------------- */
// 25-bit fixed point W is stored as 1-bit sign + 24-bit absolut value,
// e.g. {1'b(sign), 7'b0, 24'b(abs)} where sign is stored in [31] bit and 
// abs is stored in [23:0] bit.
// Do this conversion at higher level to reduce cost of transformation.
// 
// 25-bit fixed point A is stored as 25-bit 2's complement,
// but the sign bit is stored in [31] while the rest bits is stored in [23:0].
/* -------------------------------------------------------------------------- */
