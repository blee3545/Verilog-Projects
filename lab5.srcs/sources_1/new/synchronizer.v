`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 07:15:27 PM
// Design Name: 
// Module Name: AddSub4
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

module synchronizer(
    input clk_i,
    input async_i, 
    output sync_o
);

wire q1;

FDRE#(.INIT(1'b1)) ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(async_i), .Q(q1));
FDRE#(.INIT(1'b1)) ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q1), .Q(sync_o));

endmodule