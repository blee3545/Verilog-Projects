`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:31:40 PM
// Design Name: 
// Module Name: energy_manager
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


module energy_manager(
    input clk,
    input reset,
    input frame_tick,
    input hovering,
    input game_started,
    output [7:0] energy_level,
    output energy_zero,
    output energy_max
);
    //frametick edge detector
    wire frame_tick_prev;
    wire frame_pulse;
    FDRE #(.INIT(1'b0)) frame_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(frame_tick), .Q(frame_tick_prev));
    assign frame_pulse = frame_tick&~frame_tick_prev; //shoulld only load on the rising edge of the trame
    
    wire [7:0] energy;
    wire up_signal, down_signal;

    assign energy_max =(energy==8'd192);
    
    assign energy_zero =(energy==8'd0);
    
    assign up_signal =frame_pulse&&game_started && ~hovering && ~energy_max;
    assign down_signal =frame_pulse&&game_started && hovering && ~energy_zero;
    
    energy_counter_8bit energy_counter(
        .clk_i(clk),
        .up_i(up_signal),
        .dw_i(down_signal),
        .ld_i(reset),  
        .Din_i(8'd192),
        .Q_o(energy),
        .utc_o(),
        .dtc_o()
    );
    
    assign energy_level = energy;
    
endmodule
