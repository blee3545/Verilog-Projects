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

module countUD8L(
    input clk_i, 
    input up_i, 
    input dw_i,
    input ld_i, 
    input [7:0]Din_i,
    output [7:0] Q_o,
    output utc_o, 
    output dtc_o
);

wire utc0, utc1;
wire dtc0, dtc1;

countUD4L count0(
    .clk_i(clk_i), 
    .up_i(up_i), 
    .dw_i(dw_i), 
    .ld_i(ld_i), 
    .Din_i(Din_i[3:0]),
    .Q_o(Q_o[3:0]),
    .utc_o(utc0),
    .dtc_o(dtc0)
);

countUD4L count1(
    .clk_i(clk_i), 
    .up_i(up_i&utc0), 
    .dw_i(dw_i&dtc0), 
    .ld_i(ld_i), 
    .Din_i(Din_i[7:4]),
    .Q_o(Q_o[7:4]),
    .utc_o(utc1),
    .dtc_o(dtc1)
);

assign utc_o=Q_o[7]&Q_o[6]&Q_o[5]&Q_o[4]&Q_o[3]&Q_o[2]&Q_o[1]&Q_o[0];
assign dtc_o=~Q_o[7]&~Q_o[6]&~Q_o[5]&~Q_o[4]&~Q_o[3]&~Q_o[2]&~Q_o[1]&~Q_o[0];

endmodule
