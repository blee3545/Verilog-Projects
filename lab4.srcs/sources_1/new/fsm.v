`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 05:53:56 PM
// Design Name: 
// Module Name: fsm
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


module fsm(
    input clk_i,
    input Go_i,
    input anysw_i,
    input four_secs_i,
    input two_secs_i,
    input match_i,
    input won_i,
    input lost_i,
    output load_target_o,
    output reset_timer_o,
    output inc_score_o,
    output dec_score_o,
    output show_target_o,
    output flash_score_o,
    output flash_led_o
    );
    wire [6:0] state;
    wire [6:0] next_state;
    
    wire IDLE=state[0];
    wire PLAY=state[1];
    wire CORRECT=state[2];
    wire FLASH_NEW=state[3];
    wire WRONG=state[4];
    wire WIN=state[5];
    wire LOSE=state[6];
    
    assign next_state[0]=(IDLE&~Go_i)|(WRONG&four_secs_i&~lost_i)|(FLASH_NEW&two_secs_i&~won_i); //idle state when not go, wrong state, and correct
    
    assign next_state[1]=(IDLE&Go_i)|(PLAY&~anysw_i&~two_secs_i); //go to play when go, no switches, and less than 2 seconds
    
    assign next_state[2]= (PLAY&anysw_i&match_i)|(CORRECT &~two_secs_i); //correct if match and/or in corret time
    assign next_state[3]=(CORRECT&two_secs_i)|(FLASH_NEW&~two_secs_i); //flash if correct or 2 seconds havent passed
   
    assign next_state[4]= (PLAY&anysw_i&~match_i)|(WRONG &~four_secs_i)|(PLAY&~anysw_i&two_secs_i); //wrong
   

    assign next_state[5]= (FLASH_NEW&two_secs_i&won_i)|(WIN); //win state when won or flash new and won

    assign next_state[6]= (WRONG & four_secs_i & lost_i)|LOSE; //lose state when lost or wrong and lost

    FDRE #(.INIT(1'b1))ff0(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[0]),.Q(state[0]));
    FDRE #(.INIT(1'b0))ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[1]),.Q(state[1]));
    FDRE #(.INIT(1'b0))ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[2]),.Q(state[2]));
    FDRE #(.INIT(1'b0))ff3(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[3]),.Q(state[3]));
    FDRE #(.INIT(1'b0))ff4(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[4]),.Q(state[4]));
    FDRE #(.INIT(1'b0))ff5(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[5]),.Q(state[5]));
    FDRE #(.INIT(1'b0))ff6(.C(clk_i), .R(1'b0), .CE(1'b1), .D(next_state[6]),.Q(state[6]));

    assign load_target_o=IDLE&Go_i;

    assign reset_timer_o=(IDLE&Go_i)|(CORRECT&two_secs_i)|(PLAY &anysw_i&match_i)|(PLAY&anysw_i&~match_i)|(PLAY&two_secs_i); 
    
    assign inc_score_o=CORRECT&two_secs_i;
    assign dec_score_o=WRONG&four_secs_i;
    
    assign show_target_o=PLAY;
    assign flash_score_o=CORRECT|WIN|FLASH_NEW;
    assign flash_led_o=WRONG|LOSE|WIN;



endmodule
 