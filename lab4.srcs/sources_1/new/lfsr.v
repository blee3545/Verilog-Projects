`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/07/2025 04:57:42 AM
// Design Name: 
// Module Name: hex7seg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:n
// 
//////////////////////////////////////////////////////////////////////////////////

module lfsr(
    input clk_i,
    output [7:0]q_o
);
wire[7:0]q_next;
wire feedback;

assign feedback=q_o[7]^q_o[6]^q_o[5]^q_o[0]; //xor bits 7,5,4,3

assign q_next={q_o[6:0],feedback}; //shift left and insert feedback in the LSB

FDRE #(.INIT(1'b1))ff7(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[7]),.Q(q_o[7]));
FDRE #(.INIT(1'b0))ff6(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[6]),.Q(q_o[6]));
FDRE #(.INIT(1'b0))ff5(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[5]),.Q(q_o[5]));
FDRE #(.INIT(1'b0))ff4(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[4]),.Q(q_o[4]));
FDRE #(.INIT(1'b0))ff3(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[3]),.Q(q_o[3]));
FDRE #(.INIT(1'b0))ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[2]),.Q(q_o[2]));
FDRE #(.INIT(1'b0))ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[1]),.Q(q_o[1]));
FDRE #(.INIT(1'b0))ff0(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_next[0]),.Q(q_o[0]));





endmodule

