`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 06:15:03 PM
// Design Name: 
// Module Name: decoder
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


module decoder(
    input [3:0]in_i,
    output[15:0]out_o
    );
    assign out_o[0]=~in_i[3]&~in_i[2]&~in_i[1]&~in_i[0];
    assign out_o[1]=~in_i[3]&~in_i[2]&~in_i[1]& in_i[0];
    assign out_o[2]=~in_i[3]&~in_i[2]& in_i[1]&~in_i[0];
    assign out_o[3]=~in_i[3]&~in_i[2]& in_i[1]& in_i[0];
    assign out_o[4]=~in_i[3]& in_i[2]&~in_i[1]&~in_i[0];
    assign out_o[5]=~in_i[3]& in_i[2]&~in_i[1]& in_i[0];
    assign out_o[6]=~in_i[3]& in_i[2]& in_i[1]&~in_i[0];
    assign out_o[7]=~in_i[3]& in_i[2]& in_i[1]& in_i[0];
    assign out_o[8]= in_i[3]&~in_i[2]&~in_i[1]&~in_i[0];
    assign out_o[9]= in_i[3]&~in_i[2]&~in_i[1]& in_i[0];
    assign out_o[10]=in_i[3]&~in_i[2]& in_i[1]&~in_i[0];
    assign out_o[11]=in_i[3]&~in_i[2]& in_i[1]& in_i[0];
    assign out_o[12]=in_i[3]& in_i[2]&~in_i[1]&~in_i[0];
    assign out_o[13]=in_i[3]& in_i[2]&~in_i[1]& in_i[0];
    assign out_o[14]=in_i[3]& in_i[2]& in_i[1]&~in_i[0];
    assign out_o[15]=in_i[3]& in_i[2]& in_i[1]& in_i[0];
endmodule
