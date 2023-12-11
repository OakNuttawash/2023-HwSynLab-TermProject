`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.12.2023 23:35:53
// Design Name: 
// Module Name: text
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


module text(
    output reg [11:0] rgb,
    input wire [3:0] num,
    input wire reset,
    input wire p_tick,
    input wire [9:0] rx,
    input wire [9:0] ry,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [11:0] color
    );
    
    reg [19:0] seg = 0;


    always @(num)
        case (num)
            4'd0 : seg = 20'b11111000111100011111; //S
            4'd1 : seg = 20'b11111000100010001111; //C
            4'd2 : seg = 20'b11111001100110011111; //O
            4'd3 : seg = 20'b11111001111110101001; //R
            4'd4 : seg = 20'b11111000111110001111; //E
            4'd5 : seg = 20'b11111001111110001000; //P
            4'd6 : seg = 20'b00100110001000100111; //1
            4'd7 : seg = 20'b11110001111110001111; //2
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
            rgb <= seg[(relative_y/8)*4 + relative_x/8] * color;
        end else 
            rgb <= 12'h000;
    end


endmodule

