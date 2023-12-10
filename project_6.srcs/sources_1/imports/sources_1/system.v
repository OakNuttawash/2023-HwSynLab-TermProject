`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2021 09:31:37 PM
// Design Name: 
// Module Name: system
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


module system(
    input wire [11:0]sw, //vga
    input btnC, btnU, btnL, //vga
    output wire Hsync, Vsync, //vga
    output wire [3:0] vgaRed, vgaGreen, vgaBlue, //vga
    output wire RsTx, //uart
    input wire RsRx, //uart
    input wire PS2Clk,
    input wire PS2Data,
    input clk //both
    );
    
wire [7:0] data_in;
wire u1, u2, d1, d2, start , reset;

// u1 = 1 when data_in is "w"
assign u1 = data_in == 8'h77;
// d1 = 1 when data_in is "s"
assign d1 = data_in == 8'h73;
// u2 = 1 when data_in is "u"
assign u2 = data_in == 8'h75;
// d2 = 1 when data_in is "j"
assign d2 = data_in == 8'h6A;
// start = 1 when data_in is "t"
assign start = data_in == 8'h74;

uart uart(clk,RsRx,RsTx,data_in);
    
vga game(
    .clk(clk), .sw(sw),
    .push({btnL, btnU}),
    .hsync(Hsync), .vsync(Vsync),
    .rgb({vgaRed, vgaGreen, vgaBlue}),
    .PS2Clk(PS2Clk),
    .PS2Data(PS2Data),
    .u1(u1), .u2(u2), .d1(d1), .d2(d2), .start(start)
);
    
reg CLK50MHZ=0;
    always @(posedge(clk))begin
    CLK50MHZ<=~CLK50MHZ;
end


    
endmodule
