//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_top.v                                                   ////
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

`include "ps2_defines.v"
// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_top
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

    ps2_kbd_clk_pad_i,
    ps2_kbd_data_pad_i,
    ps2_kbd_clk_pad_o,
    ps2_kbd_data_pad_o,
    ps2_kbd_clk_pad_oe_o,
    ps2_kbd_data_pad_oe_o
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0] wb_sel_i ;

input [31:0]wb_adr_i, 
            wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o ;

output wb_int_o ;

input ps2_kbd_clk_pad_i,
      ps2_kbd_data_pad_i ;

output ps2_kbd_clk_pad_o,
       ps2_kbd_data_pad_o,
       ps2_kbd_clk_pad_oe_o,
       ps2_kbd_data_pad_oe_o ;

wire rx_extended,
     rx_released,
     rx_shift_key_on,
     rx_data_ready,
     rx_translated_data_ready,
     rx_read_wb,
     rx_read_tt,
     tx_write,
     tx_write_ack,
     tx_error_no_keyboard_ack,
     ps2_ctrl_kbd_data_en_,
     ps2_ctrl_kbd_clk_en_,
     ps2_ctrl_kbd_clk,
     inhibit_kbd_if ;

wire [7:0] rx_scan_code, 
           rx_translated_scan_code,
           rx_ascii,
           tx_data ;

assign ps2_kbd_clk_pad_o  = 1'b0 ;
assign ps2_kbd_data_pad_o = 1'b0 ;

ps2_io_ctrl i_ps2_io_ctrl
(
    .clk_i                   (wb_clk_i),
    .rst_i                   (wb_rst_i),
    .ps2_ctrl_kbd_clk_en_i_  (ps2_ctrl_kbd_clk_en_),
    .ps2_ctrl_kbd_data_en_i_ (ps2_ctrl_kbd_data_en_),
    .ps2_kbd_clk_pad_i       (ps2_kbd_clk_pad_i),
    .ps2_kbd_clk_pad_oe_o    (ps2_kbd_clk_pad_oe_o),
    .ps2_kbd_data_pad_oe_o   (ps2_kbd_data_pad_oe_o),
    .inhibit_kbd_if_i        (inhibit_kbd_if),
    .ps2_ctrl_kbd_clk_o      (ps2_ctrl_kbd_clk)
);

ps2_keyboard #(`PS2_TIMER_60USEC_VALUE_PP, `PS2_TIMER_60USEC_BITS_PP, `PS2_TIMER_5USEC_VALUE_PP, `PS2_TIMER_5USEC_BITS_PP, 0)
i_ps2_keyboard
(
    .clk                         (wb_clk_i),
    .reset                       (wb_rst_i),
    .ps2_clk_en_o_               (ps2_ctrl_kbd_clk_en_),
    .ps2_data_en_o_              (ps2_ctrl_kbd_data_en_),
    .ps2_clk_i                   (ps2_ctrl_kbd_clk),
    .ps2_data_i                  (ps2_kbd_data_pad_i),
    .rx_extended                 (rx_extended),
    .rx_released                 (rx_released),
    .rx_shift_key_on             (rx_shift_key_on),
    .rx_scan_code                (rx_scan_code),
    .rx_ascii                    (rx_ascii),
    .rx_data_ready               (rx_data_ready),
    .rx_read                     (rx_read_tt),
    .tx_data                     (tx_data),
    .tx_write                    (tx_write),
    .tx_write_ack_o              (tx_write_ack),
    .tx_error_no_keyboard_ack    (tx_error_no_keyboard_ack),
    .translate                   (translate)
);

ps2_wb_if i_ps2_wb_if
(
    .wb_clk_i                      (wb_clk_i),
    .wb_rst_i                      (wb_rst_i),
    .wb_cyc_i                      (wb_cyc_i),
    .wb_stb_i                      (wb_stb_i),
    .wb_we_i                       (wb_we_i),
    .wb_sel_i                      (wb_sel_i),
    .wb_adr_i                      (wb_adr_i),
    .wb_dat_i                      (wb_dat_i),
    .wb_dat_o                      (wb_dat_o),
    .wb_ack_o                      (wb_ack_o),
 
    .wb_int_o                      (wb_int_o),
 
    .rx_scancode_i                 (rx_translated_scan_code),
    .rx_data_ready_i               (rx_translated_data_ready),
    .rx_read_o                     (rx_read_wb),
    .tx_data_o                     (tx_data),
    .tx_write_o                    (tx_write),
    .tx_write_ack_i                (tx_write_ack),
    .translate_o                   (translate),
    .ps2_clk_i                     (ps2_kbd_clk_pad_i),
    .inhibit_kbd_if_o              (inhibit_kbd_if)
) ;

ps2_translation_table i_ps2_translation_table
(
    .reset_i                    (wb_rst_i),
    .clock_i                    (wb_clk_i),
    .translate_i                (translate),
    .code_i                     (rx_scan_code),
    .code_o                     (rx_translated_scan_code),
    .address_i                  (8'h00),
    .data_i                     (8'h00),
    .we_i                       (1'b0),
    .re_i                       (1'b0),
    .data_o                     (),
    .rx_data_ready_i            (rx_data_ready),
    .rx_translated_data_ready_o (rx_translated_data_ready),
    .rx_read_i                  (rx_read_wb),
    .rx_read_o                  (rx_read_tt),
    .rx_released_i              (rx_released),
    .rx_extended_i              (rx_extended)
) ;

endmodule // ps2_top
