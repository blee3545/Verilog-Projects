`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2025 09:03:31 AM
// Design Name:
// Module Name: track
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


module track(
    input clk,
    input reset,
    input frame_pulse,
    input track_enable,        
    input game_over,           
    input [5:0]random_bits, 
    input is_middle_track,     
    input [1:0]track_id,    
    output [9:0]train1_top,
    output [9:0]train1_bottom,
    output train1_active,
    output [9:0]train2_top,
    output [9:0]train2_bottom,
    output train2_active
);

    
    wire [1:0]train1_state;
    wire [1:0]train1_state_next;
    wire [9:0]train1_pos;
    wire [9:0]train1_pos_next;
    wire [6:0]train1_length;
    wire [6:0]train1_length_next;
    wire [7:0]train1_wait_counter;
    wire [7:0]train1_wait_counter_next;


    wire [1:0]train2_state;
    wire [1:0]train2_state_next;
    wire [9:0]train2_pos;
    wire [9:0]train2_pos_next;
    wire [6:0]train2_length;
    wire [6:0]train2_length_next;
    wire [7:0]train2_wait_counter;
    wire [7:0]train2_wait_counter_next;

    
    wire [1:0] IDLE;
    wire [1:0] WAIT;
    wire [1:0] MOVE;
    assign IDLE = 2'b00;
    assign WAIT = 2'b01;
    assign MOVE = 2'b10;

    //screen
    wire [9:0] screen_top;
    wire [9:0] screen_bottom;
    assign screen_top = 10'd8;      //top
    assign screen_bottom = 10'd471; //bottom

    //trigger row for middle train
    wire [9:0] trigger_row;
    assign trigger_row = ({10{is_middle_track}} & 10'd440) | ({10{~is_middle_track}} & 10'd400);


    wire [6:0] train1_random_length;
    wire [7:0] train1_random_wait;
    wire [6:0] train2_random_length;
    wire [7:0] train2_random_wait;

    // train length calcul;ator
    assign train1_random_length=7'd40 +{2'b00, random_bits[4:0]};
    assign train2_random_length =7'd40 +{2'b00, random_bits[4:0]};

    //frame offset for train delay
    wire [7:0] track_offset;
    assign track_offset= {6'd0,track_id}*8'd30;

    // this makes it so theres always a safe lane
    assign train1_random_wait=8'd30 +track_offset +{2'b00, random_bits};
    assign train2_random_wait=8'd30 +track_offset +{2'b00, random_bits};
    //train 1
    wire train1_idle, train1_wait, train1_move;
    assign train1_idle =(train1_state== IDLE);
    assign train1_wait =(train1_state ==WAIT);
    assign train1_move =(train1_state ==MOVE);

    wire train1_wait_done;
    assign train1_wait_done=(train1_wait_counter==8'd0);

    wire train1_move_done;
    assign train1_move_done=(train1_pos>screen_bottom);

    wire train1_go_to_wait;
    assign train1_go_to_wait=train1_idle&&track_enable&&frame_pulse;

    wire train1_go_to_move;
    assign train1_go_to_move=train1_wait&&train1_wait_done&&frame_pulse;

    wire train1_go_to_idle;
    assign train1_go_to_idle=train1_move&&train1_move_done&&frame_pulse;

    // train 1 next
    assign train1_state_next=({2{train1_go_to_wait}}&WAIT)|({2{train1_go_to_move}}&MOVE)|({2{train1_go_to_idle}}&IDLE)|({2{~train1_go_to_wait & ~train1_go_to_move & ~train1_go_to_idle}} & train1_state);

    wire [9:0]train1_pos_incremented;
    assign train1_pos_incremented = train1_pos + 10'd1;

    wire train1_should_move;
    assign train1_should_move = train1_move && frame_pulse && ~game_over;

    assign train1_pos_next = ({10{train1_go_to_move}}&screen_top)|({10{train1_should_move}}&train1_pos_incremented)|({10{~train1_go_to_move&~train1_should_move}} & train1_pos);


    assign train1_length_next = ({7{train1_go_to_wait}}&train1_random_length)|({7{~train1_go_to_wait}}&train1_length);


    wire [7:0] train1_wait_decremented;
    assign train1_wait_decremented = train1_wait_counter - 8'd1;

    assign train1_wait_counter_next = ({8{train1_go_to_wait}}&train1_random_wait)|({8{train1_wait &&frame_pulse&&~train1_wait_done}}&train1_wait_decremented)|({8{~train1_go_to_wait&~(train1_wait&&frame_pulse&&~train1_wait_done)}}&train1_wait_counter);


    wire train2_idle, train2_wait, train2_move;
    assign train2_idle=(train2_state==IDLE);
    assign train2_wait=(train2_state==WAIT);
    assign train2_move=(train2_state==MOVE);

    wire train2_wait_done;
    assign train2_wait_done=(train2_wait_counter==8'd0);

    wire train2_move_done;
    assign train2_move_done=(train2_pos>screen_bottom);

    wire train2_trigger;
    assign train2_trigger=train1_move&&(train1_pos>=trigger_row);

    wire train2_go_to_wait;
    assign train2_go_to_wait=train2_idle&&train2_trigger&&frame_pulse;

    wire train2_go_to_move;
    assign train2_go_to_move=train2_wait&&train2_wait_done&&frame_pulse;

    wire train2_go_to_idle;
    assign train2_go_to_idle=train2_move&&train2_move_done&&frame_pulse;

    assign train2_state_next = ({2{train2_go_to_wait}}&WAIT)|({2{train2_go_to_move}}&MOVE)|({2{train2_go_to_idle}}&IDLE)|({2{~train2_go_to_wait & ~train2_go_to_move & ~train2_go_to_idle}} & train2_state);

 
    wire [9:0] train2_pos_incremented;
    assign train2_pos_incremented=train2_pos+10'd1;

    wire train2_should_move;
    assign train2_should_move =train2_move&&frame_pulse&&~game_over;

    assign train2_pos_next=({10{train2_go_to_move}} & screen_top)|({10{train2_should_move}} & train2_pos_incremented)|({10{~train2_go_to_move & ~train2_should_move}} & train2_pos);


    assign train2_length_next=({7{train2_go_to_wait}} & train2_random_length)|({7{~train2_go_to_wait}} & train2_length);

  
    wire [7:0] train2_wait_decremented;
    assign train2_wait_decremented = train2_wait_counter - 8'd1;

    assign train2_wait_counter_next = ({8{train2_go_to_wait}} & train2_random_wait)|({8{train2_wait && frame_pulse && ~train2_wait_done}} & train2_wait_decremented)|({8{~train2_go_to_wait & ~(train2_wait && frame_pulse && ~train2_wait_done)}} & train2_wait_counter);

    //state machine
    FDRE #(.INIT(1'b0)) train1_state_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train1_state_next[0]), .Q(train1_state[0]));
    FDRE #(.INIT(1'b0)) train1_state_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train1_state_next[1]), .Q(train1_state[1]));

    //position 
    FDRE #(.INIT(1'b0)) train1_pos_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[0]), .Q(train1_pos[0]));
    FDRE #(.INIT(1'b0)) train1_pos_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[1]), .Q(train1_pos[1]));
    FDRE #(.INIT(1'b0)) train1_pos_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[2]), .Q(train1_pos[2]));
    FDRE #(.INIT(1'b0)) train1_pos_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[3]), .Q(train1_pos[3]));
    FDRE #(.INIT(1'b0)) train1_pos_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[4]), .Q(train1_pos[4]));
    FDRE #(.INIT(1'b0)) train1_pos_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[5]), .Q(train1_pos[5]));
    FDRE #(.INIT(1'b0)) train1_pos_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[6]), .Q(train1_pos[6]));
    FDRE #(.INIT(1'b0)) train1_pos_ff7(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[7]), .Q(train1_pos[7]));
    FDRE #(.INIT(1'b0)) train1_pos_ff8(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[8]), .Q(train1_pos[8]));
    FDRE #(.INIT(1'b0)) train1_pos_ff9(.C(clk), .R(reset), .CE(1'b1), .D(train1_pos_next[9]), .Q(train1_pos[9]));

    //length
    FDRE #(.INIT(1'b0)) train1_len_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[0]), .Q(train1_length[0]));
    FDRE #(.INIT(1'b0)) train1_len_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[1]), .Q(train1_length[1]));
    FDRE #(.INIT(1'b0)) train1_len_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[2]), .Q(train1_length[2]));
    FDRE #(.INIT(1'b0)) train1_len_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[3]), .Q(train1_length[3]));
    FDRE #(.INIT(1'b0)) train1_len_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[4]), .Q(train1_length[4]));
    FDRE #(.INIT(1'b0)) train1_len_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[5]), .Q(train1_length[5]));
    FDRE #(.INIT(1'b0)) train1_len_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train1_length_next[6]), .Q(train1_length[6]));


    //wait counter
    FDRE #(.INIT(1'b0)) train1_wait_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[0]), .Q(train1_wait_counter[0]));
    FDRE #(.INIT(1'b0)) train1_wait_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[1]), .Q(train1_wait_counter[1]));
    FDRE #(.INIT(1'b0)) train1_wait_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[2]), .Q(train1_wait_counter[2]));
    FDRE #(.INIT(1'b0)) train1_wait_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[3]), .Q(train1_wait_counter[3]));
    FDRE #(.INIT(1'b0)) train1_wait_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[4]), .Q(train1_wait_counter[4]));
    FDRE #(.INIT(1'b0)) train1_wait_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[5]), .Q(train1_wait_counter[5]));
    FDRE #(.INIT(1'b0)) train1_wait_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[6]), .Q(train1_wait_counter[6]));
    FDRE #(.INIT(1'b0)) train1_wait_ff7(.C(clk), .R(reset), .CE(1'b1), .D(train1_wait_counter_next[7]), .Q(train1_wait_counter[7]));

    //state machine 2
    FDRE #(.INIT(1'b0)) train2_state_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train2_state_next[0]), .Q(train2_state[0]));
    FDRE #(.INIT(1'b0)) train2_state_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train2_state_next[1]), .Q(train2_state[1]));

    //position 2
    FDRE #(.INIT(1'b0)) train2_pos_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[0]), .Q(train2_pos[0]));
    FDRE #(.INIT(1'b0)) train2_pos_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[1]), .Q(train2_pos[1]));
    FDRE #(.INIT(1'b0)) train2_pos_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[2]), .Q(train2_pos[2]));
    FDRE #(.INIT(1'b0)) train2_pos_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[3]), .Q(train2_pos[3]));
    FDRE #(.INIT(1'b0)) train2_pos_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[4]), .Q(train2_pos[4]));
    FDRE #(.INIT(1'b0)) train2_pos_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[5]), .Q(train2_pos[5]));
    FDRE #(.INIT(1'b0)) train2_pos_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[6]), .Q(train2_pos[6]));
    FDRE #(.INIT(1'b0)) train2_pos_ff7(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[7]), .Q(train2_pos[7]));
    FDRE #(.INIT(1'b0)) train2_pos_ff8(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[8]), .Q(train2_pos[8]));
    FDRE #(.INIT(1'b0)) train2_pos_ff9(.C(clk), .R(reset), .CE(1'b1), .D(train2_pos_next[9]), .Q(train2_pos[9]));

    //length 2
    FDRE #(.INIT(1'b0)) train2_len_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[0]), .Q(train2_length[0]));
    FDRE #(.INIT(1'b0)) train2_len_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[1]), .Q(train2_length[1]));
    FDRE #(.INIT(1'b0)) train2_len_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[2]), .Q(train2_length[2]));
    FDRE #(.INIT(1'b0)) train2_len_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[3]), .Q(train2_length[3]));
    FDRE #(.INIT(1'b0)) train2_len_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[4]), .Q(train2_length[4]));
    FDRE #(.INIT(1'b0)) train2_len_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[5]), .Q(train2_length[5]));
    FDRE #(.INIT(1'b0)) train2_len_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train2_length_next[6]), .Q(train2_length[6]));

    //wait counter 2
    FDRE #(.INIT(1'b0)) train2_wait_ff0(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[0]), .Q(train2_wait_counter[0]));
    FDRE #(.INIT(1'b0)) train2_wait_ff1(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[1]), .Q(train2_wait_counter[1]));
    FDRE #(.INIT(1'b0)) train2_wait_ff2(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[2]), .Q(train2_wait_counter[2]));
    FDRE #(.INIT(1'b0)) train2_wait_ff3(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[3]), .Q(train2_wait_counter[3]));
    FDRE #(.INIT(1'b0)) train2_wait_ff4(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[4]), .Q(train2_wait_counter[4]));
    FDRE #(.INIT(1'b0)) train2_wait_ff5(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[5]), .Q(train2_wait_counter[5]));
    FDRE #(.INIT(1'b0)) train2_wait_ff6(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[6]), .Q(train2_wait_counter[6]));
    FDRE #(.INIT(1'b0)) train2_wait_ff7(.C(clk), .R(reset), .CE(1'b1), .D(train2_wait_counter_next[7]), .Q(train2_wait_counter[7]));

    wire [9:0] train1_bottom_calc;
    wire [9:0] train2_bottom_calc;

    assign train1_bottom_calc =train1_pos+{{3{1'b0}},train1_length};
    assign train2_bottom_calc =train2_pos+{{3{1'b0}},train2_length};

    assign train1_top=train1_pos;
    assign train1_bottom=train1_bottom_calc;
    assign train1_active=train1_move;

    assign train2_top=train2_pos;
    assign train2_bottom=train2_bottom_calc;
    assign train2_active=train2_move;

endmodule
