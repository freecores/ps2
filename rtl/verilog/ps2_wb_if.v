//////////////////////////////////////////////////////////////////////
////                                                              ////
////  ps2_wb_if.v                                                 ////
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

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on

module ps2_wb_if
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

    tx_write_ack_i,
    tx_data_o,
    tx_write_o,
    rx_scancode_i,
    rx_data_ready_i,
    rx_read_o,
    translate_o,
    ps2_clk_i,
    inhibit_kbd_if_o
) ;

input wb_clk_i,
      wb_rst_i,
      wb_cyc_i,
      wb_stb_i,
      wb_we_i ;

input [3:0]  wb_sel_i ;

input [31:0] wb_adr_i ;

input [31:0]  wb_dat_i ;

output [31:0] wb_dat_o ;

output wb_ack_o ;

reg wb_ack_o ;

output wb_int_o ;
reg    wb_int_o ;

input tx_write_ack_i ;

input [7:0] rx_scancode_i ;
input       rx_data_ready_i ;
output      rx_read_o ;

output      tx_write_o ;
output [7:0] tx_data_o ;

output translate_o ;
input  ps2_clk_i ;

output inhibit_kbd_if_o ;

reg [7:0] input_buffer,
          output_buffer ;

assign tx_data_o = output_buffer ;

reg input_buffer_full,   // receive buffer
    output_buffer_full ; // transmit buffer

assign tx_write_o = output_buffer_full ;

wire system_flag ;
wire a2                       = 1'b0 ;
wire kbd_inhibit              = ps2_clk_i ;
wire mouse_output_buffer_full = 1'b0 ;
wire timeout                  = 1'b0 ;
wire perr                     = 1'b0 ;

wire [7:0] status_byte = {perr, timeout, mouse_output_buffer_full, kbd_inhibit, a2, system_flag, output_buffer_full, input_buffer_full} ;

reg  read_input_buffer_reg ;
wire read_input_buffer = wb_cyc_i && wb_stb_i && wb_sel_i[0] && !wb_ack_o && !read_input_buffer_reg && !wb_we_i && (wb_adr_i[2:0] == 3'h0) ;

reg  write_output_buffer_reg ;
wire write_output_buffer  = wb_cyc_i && wb_stb_i && wb_sel_i[0] && !wb_ack_o && !write_output_buffer_reg && wb_we_i  && (wb_adr_i[2:0] == 3'h0) ;

reg  read_status_register_reg ;
wire read_status_register = wb_cyc_i && wb_stb_i && wb_sel_i[0] && !wb_ack_o && !read_status_register_reg && !wb_we_i && (wb_adr_i[2:0] == 3'h4) ;

reg  send_command_reg ;
wire send_command = wb_cyc_i && wb_stb_i && wb_sel_i[0] && !wb_ack_o && !send_command_reg && wb_we_i  && (wb_adr_i[2:0] == 3'h4) ;

reg  translate_o,
     enable1,
     system,
     interrupt1 ;

reg inhibit_kbd_if_o ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        inhibit_kbd_if_o <= #1 1'b1 ;
    else if ( ps2_clk_i && (rx_data_ready_i || enable1) )
        inhibit_kbd_if_o <= #1 1'b1 ;
    else if ( !rx_data_ready_i && !enable1 )
        inhibit_kbd_if_o <= #1 1'b0 ;
        
end

wire interrupt2 = 1'b0 ;
wire enable2    = 1'b1 ;

assign system_flag = system ;

wire [7:0] command_byte = {1'b0, translate_o, enable2, enable1, 1'b0, system, interrupt2, interrupt1} ;

reg [7:0] current_command ;
reg [7:0] current_command_output ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        send_command_reg         <= #1 1'b0 ;
        read_input_buffer_reg    <= #1 1'b0 ;
        write_output_buffer_reg  <= #1 1'b0 ;
        read_status_register_reg <= #1 1'b0 ;
    end
    else
    begin
        send_command_reg         <= #1 send_command ;
        read_input_buffer_reg    <= #1 read_input_buffer ;
        write_output_buffer_reg  <= #1 write_output_buffer ;
        read_status_register_reg <= #1 read_status_register ;
    end
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        current_command <= #1 8'h0 ;
    else if ( send_command_reg )
        current_command <= #1 wb_dat_i[7:0] ;
end

reg current_command_valid,
    current_command_returns_value,
    current_command_gets_parameter,
    current_command_gets_null_terminated_string ;

reg write_output_buffer_reg_previous ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        write_output_buffer_reg_previous <= #1 1'b0 ;
    else
        write_output_buffer_reg_previous <= #1 write_output_buffer_reg ;
end

wire invalidate_current_command = 
     current_command_valid && 
     (( current_command_returns_value && read_input_buffer_reg && input_buffer_full) ||
      ( current_command_gets_parameter && write_output_buffer_reg_previous ) ||
      ( current_command_gets_null_terminated_string && write_output_buffer_reg_previous && (output_buffer == 8'h00) ) ||
      ( !current_command_returns_value && !current_command_gets_parameter && !current_command_gets_null_terminated_string )
     ) ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        current_command_valid <= #1 1'b0 ;
    else if ( invalidate_current_command )
        current_command_valid <= #1 1'b0 ;
    else if ( send_command_reg )
        current_command_valid <= #1 1'b1 ;
        
end

reg write_command_byte ;
reg current_command_output_valid ;
always@(
    current_command or
    command_byte or
    write_output_buffer_reg_previous or 
    current_command_valid or
    output_buffer
)
begin
    current_command_returns_value               = 1'b0 ;
    current_command_gets_parameter              = 1'b0 ;
    current_command_gets_null_terminated_string = 1'b0 ;
    current_command_output                      = 8'h00 ;
    write_command_byte                          = 1'b0 ;
    current_command_output_valid                = 1'b0 ;
    case(current_command)
        8'h20:begin
                  current_command_returns_value  = 1'b1 ;
                  current_command_output         = command_byte ;
                  current_command_output_valid   = 1'b1 ;
              end
        8'h60:begin
                  current_command_gets_parameter = 1'b1 ;
                  write_command_byte             = write_output_buffer_reg_previous && current_command_valid ;
              end
        8'hA1:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end 
        8'hA4:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hF1 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hA5:begin
                  current_command_gets_null_terminated_string = 1'b1 ;
              end
        8'hA6:begin
              end
        8'hA7:begin
              end 
        8'hA8:begin
              end
        8'hA9:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h02 ; // clock line stuck high
                  current_command_output_valid  = 1'b1 ;
              end
        8'hAA:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h55 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hAB:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hAD:begin
              end 
        8'hAE:begin
              end
        8'hAF:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h00 ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hC0:begin     
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hFF ;
                  current_command_output_valid  = 1'b1 ;
              end
        8'hC1:begin
              end
        8'hC2:begin
              end
        8'hD0:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'h01 ; // only system reset bit is 1
                  current_command_output_valid  = 1'b1 ;
              end
        8'hD1:begin
                  current_command_gets_parameter = 1'b1 ;
              end
        8'hD2:begin
                  current_command_gets_parameter  = 1'b1 ;
                  current_command_output          = output_buffer ;
                  current_command_output_valid    = write_output_buffer_reg_previous ;
              end
        8'hD3:begin
                  current_command_gets_parameter = 1'b1 ;
              end
        8'hD4:begin
                  current_command_gets_parameter = 1'b1 ;
              end
        8'hE0:begin
                  current_command_returns_value = 1'b1 ;
                  current_command_output        = 8'hFF ;
                  current_command_output_valid  = 1'b1 ;
              end
    endcase    
end

reg cyc_i_previous ;
reg stb_i_previous ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        cyc_i_previous <= #1 1'b0 ;
        stb_i_previous <= #1 1'b0 ;
    end
    else if ( wb_ack_o )
    begin
        cyc_i_previous <= #1 1'b0 ;
        stb_i_previous <= #1 1'b0 ;
    end
    else
    begin
        cyc_i_previous <= #1 wb_cyc_i ;
        stb_i_previous <= #1 wb_stb_i ;
    end
     
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_ack_o <= #1 1'b0 ;
    else if ( wb_ack_o )
        wb_ack_o <= #1 1'b0 ;
    else
        wb_ack_o <= #1 cyc_i_previous && stb_i_previous ;
end

reg [31:0] wb_dat_o ;
wire wb_read = read_input_buffer_reg || read_status_register_reg ;

wire [7:0] output_data = read_status_register_reg ? status_byte : input_buffer ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_dat_o <= #1 32'h0 ;
    else if ( wb_read )
        wb_dat_o <= #1 {4{output_data}} ;
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        output_buffer_full <= #1 1'b0 ;
    else if ( output_buffer_full && tx_write_ack_i)
        output_buffer_full <= #1 1'b0 ; 
    else 
        output_buffer_full <= #1 write_output_buffer_reg && (!current_command_valid || (!current_command_gets_parameter && !current_command_gets_null_terminated_string)) ;
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        output_buffer <= #1 8'h00 ;
    else if ( write_output_buffer_reg )
        output_buffer <= #1 wb_dat_i[7:0] ;
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
    begin
        translate_o <= #1 1'b0 ;
        system      <= #1 1'b0 ;
        interrupt1  <= #1 1'b0 ;
    end
    else if ( write_command_byte )
    begin
        translate_o <= #1 output_buffer[6] ;
        system      <= #1 output_buffer[2] ;
        interrupt1  <= #1 output_buffer[0] ;
    end
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        enable1 <= #1 1'b1 ;
    else if ( current_command_valid && (current_command == 8'hAE) )
        enable1 <= #1 1'b0 ;
    else if ( current_command_valid && (current_command == 8'hAD) )
        enable1 <= #1 1'b1 ;
    else if ( write_command_byte )
        enable1 <= #1 output_buffer[4] ;
        
end

wire write_input_buffer_from_command = current_command_valid && current_command_returns_value && current_command_output_valid ;
reg  write_input_buffer_from_command_reg ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        write_input_buffer_from_command_reg <= #1 1'b0 ;
    else
        write_input_buffer_from_command_reg <= #1 write_input_buffer_from_command ;
end

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer_full <= #1 1'b0 ;
    else if ( read_input_buffer_reg )
        input_buffer_full <= #1 1'b0 ;
    else if ( (write_input_buffer_from_command && !write_input_buffer_from_command_reg) || (rx_data_ready_i && !enable1) )
        input_buffer_full <= #1 1'b1 ;
end

reg input_buffer_filled_from_command ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer_filled_from_command <= #1 1'b0 ;
    else if ( read_input_buffer_reg )
        input_buffer_filled_from_command <= #1 1'b0 ;
    else if ( write_input_buffer_from_command && !write_input_buffer_from_command_reg)
        input_buffer_filled_from_command <= #1 1'b1 ;
end

reg rx_data_ready_reg ;
always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        rx_data_ready_reg <= #1 1'b0 ;
    else if ( input_buffer_filled_from_command )
        rx_data_ready_reg <= #1 1'b0 ;
    else
        rx_data_ready_reg <= #1 rx_data_ready_i ;
end

wire input_buffer_value_change = (rx_data_ready_i && !rx_data_ready_reg && !enable1) || (write_input_buffer_from_command && !write_input_buffer_from_command_reg) ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        input_buffer <= #1 8'h00 ;
    else if ( input_buffer_value_change )
        input_buffer <= #1 current_command_valid && current_command_returns_value ? current_command_output : rx_scancode_i ;
end

assign rx_read_o = enable1 || rx_data_ready_i && !input_buffer_filled_from_command && read_input_buffer_reg ;

always@(posedge wb_clk_i or posedge wb_rst_i)
begin
    if ( wb_rst_i )
        wb_int_o <= #1 1'b0 ;
    else if ( read_input_buffer_reg || enable1 || !interrupt1)
        wb_int_o <= #1 1'b0 ;
    else
        wb_int_o <= #1 input_buffer_full ;
end

endmodule // ps2_wb_if
