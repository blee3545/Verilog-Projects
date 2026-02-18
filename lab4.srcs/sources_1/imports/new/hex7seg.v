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
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hex7seg(
    input n3,
    input n2,
    input n1,
    input n0, 
    output [6:0]seg
    );
    assign seg[0]=(~n3&~n2&~n1&n0)|(~n3&n2&~n1&~n0)|(n3&n2&~n1&n0)|(n3&~n2&n1&n0);
    assign seg[1]=(~n3&n2&~n1&n0)|(n3&n1&n0)|(n2&n1&~n0)|(n3&n2&~n0);
    assign seg[2]=(~n3&~n2&n1&~n0)|(n3&n2&n1)|(n3&n2&~n0);
    assign seg[3]=(~n3&n2&~n1&~n0)|(n3&~n2&n1&~n0)|(n2&n1&n0)|(~n2&~n1&n0);
    assign seg[4]=(~n3&n0)|(~n3&n2&~n1)|(~n2&~n1&n0);
    assign seg[5]=(n3&n2&~n1&n0)|(~n3&~n2&n0)|(~n3&~n2&n1)|(~n3&n1&n0);
    assign seg[6]=(~n3&~n2&~n1)|(n3&n2&~n1&~n0)|(~n3&n2&n1&n0);
endmodule
