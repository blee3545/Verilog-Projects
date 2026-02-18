`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:36:09 PM
// Design Name: 
// Module Name: slug_controller
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

module game_state(
    input clk,
    input reset,
    input btnC,
    input collision,
    output game_started,
    output game_over
);
    wire started_reg;
    wire started_next;
    wire game_over_reg;
    wire game_over_next;

    wire btnC_prev;
    wire btnC_edge;

    FDRE #(.INIT(1'b0)) btnC_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(btnC), .Q(btnC_prev));
    assign btnC_edge = btnC & ~btnC_prev;


    assign started_next = started_reg || btnC_edge;
    assign game_over_next = game_over_reg || collision;
    FDRE #(.INIT(1'b0)) started_ff(.C(clk), .R(reset), .CE(1'b1), .D(started_next), .Q(started_reg));
    FDRE #(.INIT(1'b0)) game_over_ff(.C(clk), .R(reset), .CE(1'b1), .D(game_over_next), .Q(game_over_reg));
    
    assign game_started = started_reg && ~game_over_reg;
    assign game_over = game_over_reg;

endmodule
