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

module twos_complement_8bit(
    input [7:0] value_i,
    output [7:0] magnitude_o,
    output sign_o
    );

    assign sign_o=value_i[7];

    wire [7:0] inverted=~value_i;
    wire[7:0]negated;

    wire c0, c1, c2, c3, c4, c5, c6;

    assign negated[0]=inverted[0]^1'b1;
    assign c0=inverted[0]&1'b1;

    assign negated[1]=inverted[1]^c0;
    assign c1=inverted[1]&c0;

    assign negated[2]=inverted[2]^c1;
    assign c2=inverted[2]&c1;

    assign negated[3]=inverted[3]^c2;
    assign c3=inverted[3]&c2;

    assign negated[4]=inverted[4]^c3;
    assign c4=inverted[4]&c3;

    assign negated[5]=inverted[5]^c4;
    assign c5=inverted[5]&c4;

    assign negated[6]=inverted[6]^c5;
    assign c6=inverted[6]&c5;

    assign negated[7]=inverted[7]^c6;

    assign magnitude_o=({8{~sign_o}}&value_i)|({8{sign_o}}&negated);

endmodule