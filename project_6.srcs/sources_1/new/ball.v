`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 02:33:10 PM
// Design Name: 
// Module Name: ball
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


module ball(
        output reg [11:0] rgb,
        output lhit, rhit,
        reg [15:0] y,
        input wire clk, reset,
        input wire p_tick,
        input wire [9:0] rx,
        input wire [9:0] ry
    );
    localparam R = 5;
    
    reg [15:0] x = 320;
    initial y = 300;
    reg [15:0] dx = 10;
    reg [15:0] dy = 13;
    
    reg lhit;
    reg rhit;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            dx = 10;
            dy = 13;
            x = 320;
            y = 200;
            lhit = 0;
            rhit = 0;
        end else begin
        
            if (x <= 0) begin 
                dx = 10;
                lhit = 1;
            end else if (x >= 640) begin
                dx = -10;
                rhit = 1;
            end else begin
                lhit = 0;
                rhit = 0;
            end

            if (y >= 800) y = 0;
            
            if (y <= 0) dy = 13;
            else if (y >= 400) dy = -13;
        
            x =  x + dx;
            y = y + dy;
        
        end
        
    end
    
    
    always @(posedge p_tick) begin
        if (x-R <= rx && rx <= x+R && y-R <= ry && ry <= y+R ) 
            rgb <= 12'hfff;
        else 
            rgb <= 12'h000000;
    end
    
endmodule
