`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/16/2025 04:57:41 PM
// Design Name: 
// Module Name: ring_counter
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


module ring_counter(
    input clk_i,
    input advance_i, 
    output [3:0]ring_o
    );
    wire[3:0] next_ring;
    
    assign next_ring[3]=(advance_i&ring_o[0])|((~advance_i)&ring_o[3]); //bit 0 wraps to 3
    
    assign next_ring[2]=(advance_i&ring_o[3])|((~advance_i)&ring_o[2]);
    
    assign next_ring[1]=(advance_i&ring_o[2])|((~advance_i)&ring_o[1]);
    
    assign next_ring[0]=(advance_i&ring_o[1])|((~advance_i)&ring_o[0]); 
    
    FDRE#(.INIT(1'b1)) ff0(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_ring[0]), .Q(ring_o[0]));
    FDRE#(.INIT(1'b0)) ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_ring[1]), .Q(ring_o[1]));
    FDRE#(.INIT(1'b0)) ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_ring[2]), .Q(ring_o[2]));
    FDRE#(.INIT(1'b0)) ff3(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_ring[3]), .Q(ring_o[3]));
    
        
    
endmodule
