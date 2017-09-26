/*
 * This IP is the top of Atmel XMEGA CPU implementation.
 * 
 * Copyright (C) 2017  Iulian Gheorghiu
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

`timescale 1ns / 1ps

`define BUS_ADDR_PGM_LEN	11 /* < in 16-bit instructions */
`define BUS_ADDR_DATA_LEN	8  /* < in bytes */

module top(
	input rst,
	input clk,
	output reg [2:0]RGB0,
	output reg [2:0]RGB1,
	output reg [2:0]RGB2,
	output reg [2:0]RGB3,
	output reg [3:0]LED,
	input [3:0]SW,
	input [3:0]BTN
	);

//wire pgm_re;
wire [`BUS_ADDR_PGM_LEN-1:0] pgm_addr;
wire [15:0] pgm_data;
wire data_re;
wire data_we;
wire [`BUS_ADDR_DATA_LEN-1:0] data_addr;
wire [7:0]data_in;
wire [7:0]data_out;

wire io_re;
wire io_we;
wire [5:0] io_addr;
wire [7:0] io_out;
wire [7:0] io_in;



rom  #(
.bus_addr_pgm_width(`BUS_ADDR_PGM_LEN),
.rom_path("core1ROM.mem")
)rom(
	.pmem_a(pgm_addr),
	.pmem_d(pgm_data)
	
);

ram  #(
.bus_addr_data_width(`BUS_ADDR_DATA_LEN),
.ram_path("NONE")
)ram(
	.dmem_re(data_re),
	.dmem_we(data_we),
	.dmem_a(data_addr),
	.dmem_r(data_in),
	.dmem_w(data_out)
);

reg [7:0]out_led;
wire io_select_0 = (io_addr == 0 & (io_we | io_re)) ? 1'b1:1'b0;

always @ (*)
begin
	if(io_select_0 & io_we)
		{LED, RGB0[1], RGB1[1], RGB2[1], RGB3[1]} <= io_out;
end

assign io_in = (io_re & io_select_0) ? {BTN, SW} : 8'bz; // 

reg RST = 0;

initial begin
	RST = 0;
	#1;
	RST = 1;
	#1000;
	$finish;
end

mega_core #(
.bus_addr_pgm_width(`BUS_ADDR_PGM_LEN),
.bus_addr_data_width(`BUS_ADDR_DATA_LEN)
)core(
	.rst(~rst),
	.clk(clk),
	
	//.pgm_re(1'b1),
	.pgm_addr(pgm_addr),
	.pgm_data(pgm_data),
	
	.data_re(data_re),
	.data_we(data_we),
	.data_addr(data_addr),
	.data_in(data_in),
	.data_out(data_out),
	
	.io_re(io_re),
	.io_we(io_we),
	.io_addr(io_addr),
	.io_out(io_out),
	.io_in(io_in)
);

endmodule
