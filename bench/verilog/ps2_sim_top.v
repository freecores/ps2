//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_sim_top.v                                               ////
////                                                              ////
////  This file is part of the "ps2" project                      ////
////  http://www.opencores.org/cores/ps2/                         ////
////                                                              ////
////  Author(s):                                                  ////
////      - mihad@opencores.org                                   ////
////      - Miha Dolenc                                           ////
////                                                              ////
////  All additional information is avaliable in the README.txt   ////
////  file.                                                       ////
////                                                              ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Miha Dolenc, mihad@opencores.org          ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

module ps2_sim_top
(
    wb_clk_i,
    wb_rst_i,
    wb_cyc_i,
    wb_stb_i,
    wb_we_i,
    wb_sel_i,
    wb_adr_i,
    wb_dat_i,
    wb_dat_o,
    wb_ack_o,
 
    wb_int_o,
 
    ps2_kbd_clk_io,
    ps2_kbd_data_io
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0] wb_sel_i ;

input [31:0] wb_adr_i,
             wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o,
       wb_int_o ;
 
inout  ps2_kbd_clk_io,
       ps2_kbd_data_io ;


wire ps2_kbd_clk_pad_i  = ps2_kbd_clk_io ;
wire ps2_kbd_data_pad_i = ps2_kbd_data_io ;

wire ps2_kbd_clk_pad_o,
     ps2_kbd_data_pad_o,
     ps2_kbd_clk_pad_oe_o,
     ps2_kbd_data_pad_oe_o ;

ps2_top i_ps2_top
(
    .wb_clk_i              (wb_clk_i),
    .wb_rst_i              (wb_rst_i),
    .wb_cyc_i              (wb_cyc_i),
    .wb_stb_i              (wb_stb_i),
    .wb_we_i               (wb_we_i),
    .wb_sel_i              (wb_sel_i),
    .wb_adr_i              (wb_adr_i),
    .wb_dat_i              (wb_dat_i),
    .wb_dat_o              (wb_dat_o),
    .wb_ack_o              (wb_ack_o),
 
    .wb_int_o              (wb_int_o),
 
    .ps2_kbd_clk_pad_i     (ps2_kbd_clk_pad_i),
    .ps2_kbd_data_pad_i    (ps2_kbd_data_pad_i),
    .ps2_kbd_clk_pad_o     (ps2_kbd_clk_pad_o),
    .ps2_kbd_data_pad_o    (ps2_kbd_data_pad_o),
    .ps2_kbd_clk_pad_oe_o  (ps2_kbd_clk_pad_oe_o),
    .ps2_kbd_data_pad_oe_o (ps2_kbd_data_pad_oe_o)
) ;

assign ps2_kbd_clk_io  = ps2_kbd_clk_pad_oe_o  ? ps2_kbd_clk_pad_o  : 1'bz ;
assign ps2_kbd_data_io = ps2_kbd_data_pad_oe_o ? ps2_kbd_data_pad_o : 1'bz ;
endmodule
