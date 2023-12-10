`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2023 06:23:35 PM
// Design Name: 
// Module Name: digit
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


module digit(
    output reg [11:0] rgb,
    input wire [3:0] num,
    input wire reset,
    input wire p_tick,
    input wire [9:0] rx,
    input wire [9:0] ry,
    input wire [9:0] x,
    input wire [9:0] y
    );
    
    reg [19:0] seg = 0;

    // 0: 20'b11111001100110011111
    // 1: 20'b00100110001000100111
    // 2: 20'b11110001111110001111
    // 3: 20'b11110001111100011111
    // 4: 20'b10011001111100010001
    // 5: 20'b11111000111100011111
    // 6: 20'b11111000111110011111
    // 7: 20'b11110001000100010001
    // 8: 20'b11111001111110011111
    // 9: 20'b11111001111100010001

    always @(num)
        case (num)
            4'd0: seg = 20'b11111001100110011111;
            4'd1: seg = 20'b00100110001000100111;
            4'd2: seg = 20'b11110001111110001111;
            4'd3: seg = 20'b11110001111100011111;
            4'd4: seg = 20'b10011001111100010001;
            4'd5: seg = 20'b11111000111100011111;
            4'd6: seg = 20'b11111000111110011111;
            4'd7: seg = 20'b11110001000100010001;
            4'd8: seg = 20'b11111001111110011111;
            4'd9: seg = 20'b11111001111100010001;
            default: seg = 20'b11111001100110011111;
        endcase

    // WIDTH = 32
    // HEIGHT = 40

    reg [9:0] relative_x;
    reg [9:0] relative_y;

    always @(posedge p_tick) begin
        if (x <= rx && rx <= x + 31 && y <= ry && ry <= y+39 ) begin
            relative_x = 31 - (rx - x);
            relative_y = 39 - (ry - y);
            rgb <= seg[(relative_y/8)*4 + relative_x/8] * 12'hFFF;
        end else 
            rgb <= 12'h000;
    end


endmodule
