`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2025 09:01:55 AM
// Design Name:
// Module Name: random_gen
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

module random_gen(
    input clk,
    input reset,
    input enable,         
    output [5:0] random_out
);

    wire [5:0] lfsr_reg;
    wire [5:0] lfsr_next;

    
    wire feedback;
    assign feedback =lfsr_reg[5] ^lfsr_reg[4];

    assign lfsr_next = ({6{enable}} & {lfsr_reg[4:0], feedback}) |
                      ({6{~enable}} & lfsr_reg);

   
    FDRE #(.INIT(1'b0)) lfsr_ff0(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[0]), .Q(lfsr_reg[0]));
    FDRE #(.INIT(1'b1)) lfsr_ff1(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[1]), .Q(lfsr_reg[1]));
    FDRE #(.INIT(1'b0)) lfsr_ff2(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[2]), .Q(lfsr_reg[2]));
    FDRE #(.INIT(1'b1)) lfsr_ff3(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[3]), .Q(lfsr_reg[3]));
    FDRE #(.INIT(1'b0)) lfsr_ff4(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[4]), .Q(lfsr_reg[4]));
    FDRE #(.INIT(1'b1)) lfsr_ff5(.C(clk), .R(reset), .CE(1'b1), .D(lfsr_next[5]), .Q(lfsr_reg[5]));

    assign random_out = lfsr_reg;

endmodule
