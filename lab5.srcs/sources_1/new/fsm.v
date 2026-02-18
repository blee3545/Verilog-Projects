`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/04/2025 07:03:41 PM
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
    input reset_i,
    input L_i, 
    input R_i,
    output count_up_o,
    output count_down_o,
    output crossing_o, 
    output last_dir_o
    );

    //state[0]=IDLE;
    //state[1]=L_ONLY_ENTER;
    //state[2]=R_ONLY_ENTER;
    //state[3]=BOTH_FROM_l;
    //state[4]=BOTH_FROM_R;
    //state[5]=L_ONLY_EXIT;
    //state[6]=R_ONLY_EXIT;

    wire [6:0] state;
    wire [6:0] next_state;

    FDRE #(.INIT(1'b1)) state_ff0(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[0]), .Q(state[0]));
    FDRE #(.INIT(1'b0)) state_ff1(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[1]), .Q(state[1]));
    FDRE #(.INIT(1'b0)) state_ff2(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[2]), .Q(state[2]));
    FDRE #(.INIT(1'b0)) state_ff3(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[3]), .Q(state[3]));
    FDRE #(.INIT(1'b0)) state_ff4(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[4]), .Q(state[4]));
    FDRE #(.INIT(1'b0)) state_ff5(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[5]), .Q(state[5]));
    FDRE #(.INIT(1'b0)) state_ff6(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_state[6]), .Q(state[6]));

    // inputs
    wire both_unblocked =L_i &R_i;
    wire left_blocked = ~L_i&R_i;
    wire right_blocked= L_i&~R_i;
    wire both_blocked =~L_i & ~R_i;

    // Transitions from IDLE
    wire idle_to_l_enter =state[0]&left_blocked;
    wire idle_to_r_enter =state[0]&right_blocked;
    wire stay_idle = state[0]&both_unblocked;

    // From L_ONLY_ENTER
    wire l_enter_to_idle = state[1]&both_unblocked;
    wire l_enter_to_both_l = state[1]&both_blocked;
    wire l_enter_to_r_enter = state[1]&right_blocked;
    wire stay_l_enter = state[1]&left_blocked;

    // From R_ONLY_ENTER
    wire r_enter_to_idle = state[2]&both_unblocked;
    wire r_enter_to_both_r= state[2]&both_blocked;
    wire r_enter_to_l_enter =state[2]&left_blocked;
    wire stay_r_enter = state[2]&right_blocked;
    
    // From BOTH_FROM_L
    wire both_l_to_r_exit =state[3]&right_blocked;
    wire both_l_to_l_enter =state[3]& left_blocked;
    wire both_l_to_idle = state[3] &both_unblocked;
    wire stay_both_l= state[3]& both_blocked;

    // From BOTH_FROM_R
    wire both_r_to_l_exit= state[4]&left_blocked;
    wire both_r_to_r_enter =state[4] &right_blocked;
    wire both_r_to_idle = state[4] &both_unblocked;
    wire stay_both_r=state[4] &both_blocked;

    // From L_ONLY_EXIT
    wire l_exit_to_idle =state[5]&both_unblocked;
    wire l_exit_to_both_r= state[5]&both_blocked;
    wire l_exit_to_r_enter= state[5]&right_blocked;
    wire stay_l_exit = state[5]&left_blocked;

    // From R_ONLY_EXIT
    wire r_exit_to_idle=state[6]&both_unblocked;
    wire r_exit_to_both_l=state[6]& both_blocked;
    wire r_exit_to_l_enter = state[6]&left_blocked;
    wire stay_r_exit = state[6]&right_blocked;

    // Next state logic
    assign next_state[0]=stay_idle | l_enter_to_idle | r_enter_to_idle | l_exit_to_idle | r_exit_to_idle | both_l_to_idle | both_r_to_idle;
    assign next_state[1] = idle_to_l_enter | stay_l_enter | both_l_to_l_enter | r_exit_to_l_enter | r_enter_to_l_enter;
    assign next_state[2] = idle_to_r_enter | stay_r_enter | both_r_to_r_enter | l_exit_to_r_enter | l_enter_to_r_enter;
    assign next_state[3] = l_enter_to_both_l | stay_both_l | r_exit_to_both_l;
    assign next_state[4] = r_enter_to_both_r | stay_both_r | l_exit_to_both_r;
    assign next_state[5] = both_r_to_l_exit | stay_l_exit;
    assign next_state[6] = both_l_to_r_exit | stay_r_exit;

    // Output logic
    assign count_up_o = r_exit_to_idle;    // left to right crosssing
    assign count_down_o = l_exit_to_idle;  // right to left crossing
    assign crossing_o = ~state[0];         // ~idle
    
    // Last direction register
    wire last_dir;
    wire next_last_dir = (count_down_o)|((~count_up_o)&last_dir);
    
    FDRE #(.INIT(1'b0)) last_dir_ff(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_last_dir), .Q(last_dir));
    
    assign last_dir_o = last_dir;



endmodule
