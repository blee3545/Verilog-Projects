`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/03/2025 06:43:50 AM
// Design Name: 
// Module Name: vga_sync_tb
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


module vga_sync_tb();
    // Inputs
    reg [9:0] hcount;
    reg [9:0] vcount;

    // Outputs
    wire hsync;
    wire vsync;
    wire active;

    // Instantiate the Unit Under Test (UUT)
    vga_sync uut (
        .hcount(hcount),
        .vcount(vcount),
        .hsync(hsync),
        .vsync(vsync),
        .active(active)
    );

    initial begin
        // Initialize Inputs
        hcount = 0;
        vcount = 0;

        // Wait for global reset
        #100;

        // Test vsync behavior around vcount = 490 and 491
        // Start before the vsync pulse
        vcount = 10'd488;
        hcount = 10'd100;
        #10;

        vcount = 10'd489;
        #10;

        // Vsync should go LOW at vcount = 490
        vcount = 10'd490;
        #10;

        // Vsync should still be LOW at vcount = 491
        vcount = 10'd491;
        #10;

        // Vsync should go back HIGH at vcount = 492
        vcount = 10'd492;
        #10;

        vcount = 10'd493;
        #10;

        // Test a few more vcounts to show the pattern
        vcount = 10'd494;
        #10;

        vcount = 10'd500;
        #10;

        // Also test at beginning of frame
        vcount = 10'd0;
        #10;

        vcount = 10'd1;
        #10;

        $finish;
    end

    // Monitor output
    initial begin
        $monitor("Time=%0t vcount=%d hcount=%d vsync=%b hsync=%b active=%b",
                 $time, vcount, hcount, vsync, hsync, active);
    end

endmodule
