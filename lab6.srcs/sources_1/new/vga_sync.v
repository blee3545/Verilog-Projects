`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:36:09 PM
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


module vga_sync(
    input [9:0] hcount,
    input [9:0] vcount,
    output hsync,
    output vsync,
    output active
);
    wire hsync_on;
    assign hsync_on=(hcount>=10'd656)&&(hcount<=10'd751);
    assign hsync=~hsync_on;

    wire vsync_on;
    assign vsync_on=(vcount==10'd490)||(vcount==10'd491);
    assign vsync=~vsync_on;
    
    assign active=(hcount < 10'd640)&&(vcount<10'd480);
    
endmodule
