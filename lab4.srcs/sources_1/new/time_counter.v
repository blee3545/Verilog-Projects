`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 06:07:18 PM
// Design Name: 
// Module Name: time_counter
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


module time_counter(
    input clk_i,
    input inc_i,
    input dec_i, 
    input reset_i, 
    input [5:0]din,
    output [5:0]q_o
    );
    wire [15:0]q_full;

    wire [15:0]din_extended;
    assign din_extended={10'b0000000000, din};

    countUD16L counter_16bit(
        .clk_i(clk_i), 
        .up_i(inc_i), 
        .dw_i(dec_i), 
        .ld_i(reset_i), 
        .Din_i(din_extended), 
        .Q_o(q_full), 
        .utc_o(), 
        .dtc_o()
        );

    assign q_o=q_full[5:0];


    

endmodule
