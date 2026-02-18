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


module AddSub4(
    input [3:0] A_i,
    input [3:0] B_i,
    input sub_i, 
    output[3:0] S_o,
    output cout_o
    );
    wire [3:0] changeB;
    mux4bit choose (.s(sub_i), .i0(B_i), .i1(~B_i), .y(changeB));
    Add4 add (.A_i(A_i), .B_i(changeB), .cin_i(sub_i), .S_o(S_o), .cout_o(cout_o));
    
endmodule

module FA(
    input A_i,
    input B_i,
    input cin_i,
    output S_o,
    output cout_o
    );
    assign cout_o=(A_i&B_i)|(cin_i&(A_i^B_i));
    assign S_o=A_i^B_i^cin_i;
endmodule

module Add4(
    input [3:0]A_i,
    input [3:0]B_i,
    input cin_i, 
    output [3:0]S_o,
    output cout_o
    );
    wire c1, c2, c3;
    FA c01 (.A_i (A_i[0]), .B_i (B_i[0]),.cin_i(cin_i),.S_o(S_o[0]),.cout_o(c1));
    FA c12 (.A_i (A_i[1]), .B_i (B_i[1]),.cin_i(c1),.S_o(S_o[1]), .cout_o(c2));
    FA c23 (.A_i (A_i[2]), .B_i (B_i[2]),.cin_i(c2),.S_o(S_o[2]),.cout_o(c3));
    FA c34 (.A_i (A_i[3]), .B_i (B_i[3]),.cin_i(c3), .S_o(S_o[3]), .cout_o(cout_o));
   
endmodule

module mux4bit(
    input s, 
    input [3:0] i0, 
    input [3:0] i1, 
    output [3:0] y
    );
    assign y=({4{~s}}&i0)|({4{s}}&i1);
endmodule
