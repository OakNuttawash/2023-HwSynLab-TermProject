`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2021 09:36:46 PM
// Design Name: 
// Module Name: vga_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// from https://embeddedthoughts.com/2016/07/29/driving-a-vga-monitor-using-an-fpga/
// there are vga_sync and vga
// modify something in vga

module vga_sync(
    input wire clk, reset,
    output wire hsync, vsync, video_on, p_tick,
    output wire [9:0] x, y
	);
	
	// constant declarations for VGA sync parameters
	localparam H_DISPLAY       = 640; // horizontal display area
	localparam H_L_BORDER      =  48; // horizontal left border
	localparam H_R_BORDER      =  16; // horizontal right border
	localparam H_RETRACE       =  96; // horizontal retrace
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	localparam V_DISPLAY       = 480; // vertical display area
	localparam V_T_BORDER      =  10; // vertical top border
	localparam V_B_BORDER      =  33; // vertical bottom border
	localparam V_RETRACE       =   2; // vertical retrace
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
    localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	
	// mod-4 counter to generate 25 MHz pixel tick
	reg [1:0] pixel_reg;
	wire [1:0] pixel_next;
	wire pixel_tick;
	
	always @(posedge clk, posedge reset)
		if(reset) pixel_reg <= 0;
		else pixel_reg <= pixel_next;
	
	assign pixel_next = pixel_reg + 1; // increment pixel_reg 
	
	assign pixel_tick = (pixel_reg == 0); // assert tick 1/4 of the time
	
	// registers to keep track of current pixel location
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
	
	// register to keep track of vsync and hsync signal states
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
 
	// infer registers
	always @(posedge clk, posedge reset)
		if(reset) begin
            v_count_reg <= 0;
            h_count_reg <= 0;
            vsync_reg   <= 0;
            hsync_reg   <= 0;
		end
		else begin
            v_count_reg <= v_count_next;
            h_count_reg <= h_count_next;
            vsync_reg   <= vsync_next;
            hsync_reg   <= hsync_next;
		end
			
	// next-state logic of horizontal vertical sync counters
	always @* begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			         : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			         : v_count_reg;
    end
    
    // hsync and vsync are active low signals
    // hsync signal asserted during horizontal retrace
    assign hsync_next = (h_count_reg >= START_H_RETRACE) && (h_count_reg <= END_H_RETRACE);

    // vsync signal asserted during vertical retrace
    assign vsync_next = (v_count_reg >= START_V_RETRACE) && (v_count_reg <= END_V_RETRACE);

    // video only on when pixels are in both horizontal and vertical display region
    assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);

    // output signals
    assign hsync  = hsync_reg;
    assign vsync  = vsync_reg;
    assign x      = h_count_reg;
    assign y      = v_count_reg;
    assign p_tick = pixel_tick;
endmodule


////////////////////////////////////////////////
module vga(
    input wire clk,
    input wire [11:0] sw,
    input wire [1:0] push,
	input wire PS2Clk,
	input wire PS2Data,
    output wire hsync, vsync,
    output wire [11:0] rgb,
	input wire u1, u2, d1, d2, start
	);
	
	parameter WIDTH = 640;
	parameter HEIGHT = 500;
	
	parameter SCALE = 20;

    // Clock
    wire gClk;
    wire [SCALE:0] tclk;
    
    assign tclk[0]=clk;
    
    genvar c;
    generate for(c=0;c<SCALE;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate
    
    clockDiv fdivTarget(gClk,tclk[SCALE]);
	
	// register for Basys 2 8-bit RGB DAC 
	reg [11:0] rgb_reg;
	reg reset = 0;
	wire [9:0] x, y;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;
	wire p_tick;

    // instantiate vga_sync
    vga_sync vga_sync_unit (
        .clk(clk), .reset(reset), 
        .hsync(hsync), .vsync(vsync), .video_on(video_on), .p_tick(p_tick), 
        .x(x), .y(y)
        );

	// compute gradient
    reg state = 0;
        
    reg [6:0] score1 = 0;
	reg [6:0] score2 = 0;
        
    wire [11:0] rgb_ball;
    wire lhit, rhit;
	wire [15:0] by;
    ball ball_unit(
        rgb_ball,
        lhit, rhit,
		by,
        gClk, push | !state,   
        p_tick,
        x,
        y
    );

	wire [11:0] rgb_digit10;
	digit digit10(
		.rgb(rgb_digit10),
		.num(score1 % 10),
		.reset(reset),
		.p_tick(p_tick),
		.rx(x),
		.ry(y),
		.x(180),
		.y(420)
	);

	wire [11:0] rgb_digit11;
	digit digit11(
		.rgb(rgb_digit11),
		.num(score1 / 10),
		.reset(reset),
		.p_tick(p_tick),
		.rx(x),
		.ry(y),
		.x(140),
		.y(420)
	);

	wire [11:0] rgb_digit20;
	digit digit20(
		.rgb(rgb_digit20),
		.num(score2 % 10),
		.reset(reset),
		.p_tick(p_tick),
		.rx(x),
		.ry(y),
		.x(500),
		.y(420)
	);

	wire [11:0] rgb_digit21;
	digit digit21(
		.rgb(rgb_digit21),
		.num(score2 / 10),
		.reset(reset),
		.p_tick(p_tick),
		.rx(x),
		.ry(y),
		.x(460),
		.y(420)
	);

    wire [11:0] rgb_bar1;
	wire [15:0] py1;
	bar bar1(
        rgb_bar1,
		py1,
        gClk, reset,
        p_tick,
        x,
        y,
        2,
        u1, d1
    );

	wire [11:0] rgb_bar2;
	wire [15:0] py2;
	bar bar2(
		rgb_bar2,
		py2,
		gClk, reset,
		p_tick,
		x,
		y,
		630,
		u2, d2
	);
    


	always @(posedge gClk) begin
		if (start) state = 1;
		if (push) begin
			state = 0;
			score1 = 0;
			score2 = 0;
		end

		if (lhit && (by+60 < py1 || by > py1+60)) begin
			state = 0;
			if (score2 < 99) score2 <= score2 + 1;
		end

		if (rhit && (by+60 < py2 || by > py2+60)) begin
			state = 0;
			if (score1 < 99) score1 <= score1 + 1;
		end
	end

	always @(posedge p_tick) begin 
	   rgb_reg <= rgb_ball | rgb_bar1 | rgb_bar2 | rgb_digit10 | rgb_digit11 | rgb_digit20 | rgb_digit21;
	end

    // output
    assign rgb = (video_on) ? rgb_reg : 12'b0;
endmodule