`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/05/2025 10:14:18 PM
// Design Name: 
// Module Name: tb_lab5
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

module tb_lab5();

    // Inputs
    reg clkin;
    reg btnU;
    reg btnL;
    reg btnR;
    
    // Outputs
    wire [6:0] seg;
    wire [3:0] an;
    wire [15:0] led;
    
    // Instantiate the Unit Under Test (UUT)
    top uut (
        .clkin(clkin),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .seg(seg),
        .an(an),
        .led(led)
    );
    
    // Clock generation - 100MHz
    initial begin
        clkin = 0;
        forever #5 clkin = ~clkin;
    end
    
    // Test stimulus
    initial begin
        // Initialize
        btnU = 0;
        btnL = 1;
        btnR = 1;
        
        // Reset
        #1000;
        btnU = 1;
        #1000;
        btnU = 0;
        #2000;
        
        // Test 1: Left-to-Right
        btnL = 0; #5000;
        btnR = 0; #5000;
        btnL = 1; #5000;
        btnR = 1; #5000;
        #10000;
        
        // Test 2: Right-to-Left
        btnR = 0; #5000;
        btnL = 0; #5000;
        btnR = 1; #5000;
        btnL = 1; #5000;
        #10000;
        
        // Test 3: Indecisive turkey
        btnL = 0; #5000;
        btnR = 0; #5000;
        btnR = 1; #5000;
        btnR = 0; #5000;
        btnL = 1; #5000;
        btnR = 1; #5000;
        #10000;
        
        // Test 4: Turkey backs out
        btnR = 0; #5000;
        btnL = 0; #5000;
        btnL = 1; #5000;
        btnR = 1; #5000;
        #10000;
        
        // Test 5: Multiple R-to-L
        btnR = 0; #5000;
        btnL = 0; #5000;
        btnR = 1; #5000;
        btnL = 1; #5000;
        #10000;
        
        btnR = 0; #5000;
        btnL = 0; #5000;
        btnR = 1; #5000;
        btnL = 1; #5000;
        #5000000;
        
        $finish;
    end

endmodule