`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 03:55:06 PM
// Design Name: 
// Module Name: bar
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


module bar(
        output reg [11:0] rgb,
        output y,
        input wire clk, reset,
        input wire p_tick,
        input wire [9:0] rx,
        input wire [9:0] ry,
        input wire [9:0] x,
        input wire up, down
    );
    localparam W = 2;
    localparam H = 70;
    
    reg [15:0] y = 300;
    reg [15:0] dy = 0;
    
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            y = 300;
            dy = 0;
        end else begin
            if (y >= 800 || y <= H) y = H;
            else if (y >= 400-H) y = 400-H;

            if (up) dy = -10;
            else if (down) dy = 10;
            else dy = 0;
        
            y = y + dy;
        
        end
        
    end
    
    
    always @(posedge p_tick) begin
        if (x <= rx+W && rx <= x+W && y <= ry+H && ry <= y+H ) 
            rgb <= 12'hfff;
        else 
            rgb <= 12'h000;
    end
    
endmodule

