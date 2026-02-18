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


module slug_controller(
    input clk,
    input reset, 
    input frame_tick,
    input btnL,
    input btnR,
    input btnU,
    input energy_zero, 
    input game_started,
    output [9:0]slug_x,
    output hovering,
    output [1:0] current_track
    );

    wire[2:0]state;
    wire [2:0]next_state;
    wire[9:0]slug_x_reg;
    wire[9:0]slug_x_next;
    wire [1:0]track_reg;
    wire [1:0]track_next;

    wire hover_reg;
    wire hover_next;
    
    //position trackers
    wire [9:0]left_track_pos;
    wire [9:0]middle_track_pos;
    wire [9:0]right_track_pos;

    assign left_track_pos =10'd258;    
    assign middle_track_pos =10'd328;
    assign right_track_pos =10'd398;   

    
    // edge detection for frame_tick
    wire frame_tick_prev;
    wire frame_pulse;
    FDRE #(.INIT(1'b0)) frame_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(frame_tick), .Q(frame_tick_prev));
    assign frame_pulse = frame_tick & ~frame_tick_prev;
    
    //edge detector for btn
    wire btnL_prev,btnR_prev,btnU_prev;
    wire btnL_edge,btnR_edge,btnU_edge;

    FDRE #(.INIT(1'b0)) btnL_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(btnL), .Q(btnL_prev));
    FDRE #(.INIT(1'b0)) btnR_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(btnR), .Q(btnR_prev));
    FDRE #(.INIT(1'b0)) btnU_prev_ff(.C(clk), .R(reset), .CE(1'b1), .D(btnU), .Q(btnU_prev));

    assign btnL_edge =btnL & ~btnL_prev;
    assign btnR_edge =btnR & ~btnR_prev;
    assign btnU_edge =btnU & ~btnU_prev; //rising edge
    
    wire at_left_pos, at_middle_pos, at_right_pos;
    assign at_left_pos =(slug_x_reg== left_track_pos);
    assign at_middle_pos=(slug_x_reg== middle_track_pos);
    assign at_right_pos=(slug_x_reg ==right_track_pos);
    
    wire on_middle_track;
    assign on_middle_track = (track_reg == 2'd1);
    
   
    wire can_start_hover;
    assign can_start_hover =on_middle_track&&at_middle_pos&&~energy_zero&& btnU_edge;

    wire stop_hover;
    assign stop_hover =~btnU||energy_zero;  
    
    wire idle_state, move_left_state, move_right_state, hover_state;
    assign idle_state=(state==3'b000);
    assign move_left_state=(state==3'b001);
    assign move_right_state=(state==3'b010);
    assign hover_state=(state ==3'b011);
    
    wire go_to_idle, go_to_move_left, go_to_move_right, go_to_hover;
    
    //from idlle
    wire idle_to_left, idle_to_right, idle_to_hover;
    assign idle_to_left=game_started&&btnL_edge&&(track_reg!=2'd0);
    assign idle_to_right=game_started&&btnR_edge&&(track_reg!=2'd2);
    assign idle_to_hover=game_started&&can_start_hover;  // Use edge-triggered start condition
    
    // from move left
    wire move_left_done;
    wire target_is_left, target_is_middle_from_right;
    assign target_is_left=(track_reg == 2'd0);           // Moving to left track
    assign target_is_middle_from_right=(track_reg == 2'd1);  // Moving to middle from right
    assign move_left_done=(target_is_left & at_left_pos)|(target_is_middle_from_right&at_middle_pos);

    //from move right
    wire move_right_done;
    wire target_is_right, target_is_middle_from_left;
    assign target_is_right=(track_reg==2'd2);          
    assign target_is_middle_from_left=(track_reg==2'd1);  
    assign move_right_done=(target_is_right&at_right_pos)|(target_is_middle_from_left&at_middle_pos);
    
    // from hover
    wire hover_done;
    assign hover_done = stop_hover;
    
    assign go_to_move_left=idle_state&&idle_to_left;
    assign go_to_move_right=idle_state&&idle_to_right;
    assign go_to_hover=idle_state&&idle_to_hover;
    assign go_to_idle=(move_left_state&&move_left_done)||(move_right_state&&move_right_done)||(hover_state&&hover_done);
    

    wire [2:0] state_if_move_left, state_if_move_right, state_if_hover, state_if_idle;
    assign state_if_move_left =3'b001;    
    assign state_if_move_right =3'b010;  
    assign state_if_hover =3'b011;       
    assign state_if_idle =3'b000;        
    
    assign next_state = ({3{go_to_move_left}} & state_if_move_left)|({3{go_to_move_right & ~go_to_move_left}} & state_if_move_right)|({3{go_to_hover & ~go_to_move_left & ~go_to_move_right}} & state_if_hover)|({3{go_to_idle &~go_to_move_left&~go_to_move_right & ~go_to_hover}} & state_if_idle)|({3{~go_to_move_left & ~go_to_move_right & ~go_to_hover & ~go_to_idle}} & state);
    //update track when moving
    wire track_decrement, track_increment;
    assign track_decrement =idle_state&&idle_to_left;  //decrement when left
    assign track_increment =idle_state&&idle_to_right; // increment when right

    wire [1:0] track_decremented, track_incremented;
    assign track_decremented=track_reg-2'd1;
    assign track_incremented=track_reg+2'd1;

    assign track_next =({2{track_decrement}} &track_decremented) |({2{track_increment & ~track_decrement}} & track_incremented) |({2{~track_decrement & ~track_increment}} & track_reg);
    
    // position update
    wire [9:0] pos_minus_2, pos_plus_2;
    assign pos_minus_2=slug_x_reg-10'd2;
    assign pos_plus_2=slug_x_reg+10'd2;
    
    wire update_position;
    assign update_position =frame_pulse&&(move_left_state ||move_right_state);
    wire [9:0] pos_if_moving;
    assign pos_if_moving =({10{move_left_state}}&pos_minus_2)|({10{move_right_state&~move_left_state}} &pos_plus_2);
    
    assign slug_x_next=({10{update_position}}&pos_if_moving)|({10{~update_position}} & slug_x_reg);
    assign hover_next =hover_state;
    
    
    FDRE #(.INIT(1'b0)) state_ff0(.C(clk), .R(reset), .CE(1'b1), .D(next_state[0]), .Q(state[0]));
    FDRE #(.INIT(1'b0)) state_ff1(.C(clk), .R(reset), .CE(1'b1), .D(next_state[1]), .Q(state[1]));
    FDRE #(.INIT(1'b0)) state_ff2(.C(clk), .R(reset), .CE(1'b1), .D(next_state[2]), .Q(state[2]));
    
    // track registers
    FDRE #(.INIT(1'b1)) track_ff0(.C(clk), .R(reset), .CE(1'b1), .D(track_next[0]), .Q(track_reg[0]));
    FDRE #(.INIT(1'b0)) track_ff1(.C(clk), .R(reset), .CE(1'b1), .D(track_next[1]), .Q(track_reg[1]));
    
    //position registers
    FDRE #(.INIT(1'b0)) pos_ff0(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[0]), .Q(slug_x_reg[0]));
    FDRE #(.INIT(1'b0)) pos_ff1(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[1]), .Q(slug_x_reg[1]));
    FDRE #(.INIT(1'b0)) pos_ff2(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[2]), .Q(slug_x_reg[2]));
    FDRE #(.INIT(1'b1)) pos_ff3(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[3]), .Q(slug_x_reg[3]));
    FDRE #(.INIT(1'b0)) pos_ff4(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[4]), .Q(slug_x_reg[4]));
    FDRE #(.INIT(1'b0)) pos_ff5(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[5]), .Q(slug_x_reg[5]));
    FDRE #(.INIT(1'b1)) pos_ff6(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[6]), .Q(slug_x_reg[6]));
    FDRE #(.INIT(1'b0)) pos_ff7(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[7]), .Q(slug_x_reg[7]));
    FDRE #(.INIT(1'b1)) pos_ff8(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[8]), .Q(slug_x_reg[8]));
    FDRE #(.INIT(1'b0)) pos_ff9(.C(clk), .R(reset), .CE(1'b1), .D(slug_x_next[9]), .Q(slug_x_reg[9]));
    

    FDRE #(.INIT(1'b0)) hover_ff(.C(clk), .R(reset), .CE(1'b1), .D(hover_next), .Q(hover_reg));
    

    assign slug_x = slug_x_reg;
    assign hovering = hover_reg;
    assign current_track = track_reg;

endmodule
