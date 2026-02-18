`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:36:09 PM
// Design Name: 
// Module Name: top
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


module top(
    input clkin,
    input btnC,
    input btnU,
    input btnL,
    input btnR,
    input btnD, 
    output [3:0]an,
    output [6:0]seg,
    output dp,
    output hdmi_hsync,
    output hdmi_vsync,
    output [3:0]hdmiRed,
    output [3:0]hdmiGreen,
    output [3:0]hdmiBlue,
    output hdmi_clk,
    output hdmi_dispen
);
    
    wire clk;  
    wire digsel;  
    
    labVGA_clks vga_clocks(
        .clkin(clkin),
        .greset(btnD),
        .clk(clk),
        .digsel(digsel)
    );
    
    wire [9:0] hcount, vcount;
    wire frame_tick;
    wire active;
    
    vga_counters counters(
        .clk(clk),
        .reset(btnD),
        .hcount(hcount),
        .vcount(vcount),
        .frame_tick(frame_tick)
    );
    
    vga_sync sync_gen(
        .hcount(hcount),
        .vcount(vcount),
        .hsync(hdmi_hsync),
        .vsync(hdmi_vsync),
        .active(active)
    );
    
    wire game_started;
    wire game_over;
    wire collision;

    game_state game_ctrl(
        .clk(clk),
        .reset(btnD),
        .btnC(btnC),
        .collision(collision),
        .game_started(game_started),
        .game_over(game_over)
    );
    
    wire [7:0] energy_level;
    wire energy_zero;
    wire energy_max;
    wire hovering;
    
    energy_manager energy(
        .clk(clk),
        .reset(btnD),
        .frame_tick(frame_tick),
        .hovering(hovering),
        .game_started(game_started),
        .energy_level(energy_level),
        .energy_zero(energy_zero),
        .energy_max(energy_max)
    );
    
    wire [9:0]slug_x;
    wire [1:0]current_track;

    slug_controller slug(
        .clk(clk),
        .reset(btnD),
        .frame_tick(frame_tick),
        .btnL(btnL),
        .btnR(btnR),
        .btnU(btnU),
        .energy_zero(energy_zero),
        .game_started(game_started),
        .slug_x(slug_x),
        .hovering(hovering),
        .current_track(current_track)
    );

    //flash
    wire [3:0]flash_counter;
    wire [3:0]flash_counter_next;
    wire flash_pulse;
    wire flash_signal;

    // frame tick accounted for counting
    wire frame_tick_prev;
    wire frame_pulse;
    FDRE #(.INIT(1'b0)) frame_tick_prev_ff(.C(clk), .R(btnD), .CE(1'b1), .D(frame_tick), .Q(frame_tick_prev));
    assign frame_pulse=frame_tick&~frame_tick_prev;

    wire counter_at_15;
    assign counter_at_15=(flash_counter == 4'd15);
    wire [3:0] flash_counter_inc;
    assign flash_counter_inc=flash_counter + 4'd1;
    assign flash_counter_next=({4{frame_pulse && counter_at_15}}&4'd0)|({4{frame_pulse&&~counter_at_15}}&flash_counter_inc)|({4{~frame_pulse}} & flash_counter);

    FDRE #(.INIT(1'b0)) flash_cnt_ff0(.C(clk), .R(btnD), .CE(1'b1), .D(flash_counter_next[0]), .Q(flash_counter[0]));
    FDRE #(.INIT(1'b0)) flash_cnt_ff1(.C(clk), .R(btnD), .CE(1'b1), .D(flash_counter_next[1]), .Q(flash_counter[1]));
    FDRE #(.INIT(1'b0)) flash_cnt_ff2(.C(clk), .R(btnD), .CE(1'b1), .D(flash_counter_next[2]), .Q(flash_counter[2]));
    FDRE #(.INIT(1'b0)) flash_cnt_ff3(.C(clk), .R(btnD), .CE(1'b1), .D(flash_counter_next[3]), .Q(flash_counter[3]));

    assign flash_signal = (flash_counter < 4'd8);

    wire [5:0] random_bits;
    random_gen rng(
        .clk(clk),
        .reset(btnD),
        .enable(frame_pulse),
        .random_out(random_bits)
    );

    // track timing control
    wire [9:0]track_timer;
    wire [9:0]track_timer_next;
    wire track_timer_enable;
    wire left_track_enable;
    wire right_track_enable;
    wire middle_track_enable;

    //counts up to 480 frames
    assign track_timer_enable =game_started &&(track_timer < 10'd480);
    wire [9:0] track_timer_inc;
    assign track_timer_inc=track_timer + 10'd1;
    assign track_timer_next=({10{frame_pulse && track_timer_enable}} & track_timer_inc)|({10{~(frame_pulse && track_timer_enable)}} & track_timer);

    FDRE #(.INIT(1'b0)) track_timer_ff0(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[0]), .Q(track_timer[0]));
    FDRE #(.INIT(1'b0)) track_timer_ff1(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[1]), .Q(track_timer[1]));
    FDRE #(.INIT(1'b0)) track_timer_ff2(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[2]), .Q(track_timer[2]));
    FDRE #(.INIT(1'b0)) track_timer_ff3(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[3]), .Q(track_timer[3]));
    FDRE #(.INIT(1'b0)) track_timer_ff4(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[4]), .Q(track_timer[4]));
    FDRE #(.INIT(1'b0)) track_timer_ff5(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[5]), .Q(track_timer[5]));
    FDRE #(.INIT(1'b0)) track_timer_ff6(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[6]), .Q(track_timer[6]));
    FDRE #(.INIT(1'b0)) track_timer_ff7(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[7]), .Q(track_timer[7]));
    FDRE #(.INIT(1'b0)) track_timer_ff8(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[8]), .Q(track_timer[8]));
    FDRE #(.INIT(1'b0)) track_timer_ff9(.C(clk), .R(btnD), .CE(1'b1), .D(track_timer_next[9]), .Q(track_timer[9]));

    //tracks starters
    assign left_track_enable =game_started &&~game_over;  // 0 seconds
    assign right_track_enable =game_started&& ~game_over&&(track_timer >= 10'd120);  //2 seconds
    assign middle_track_enable =game_started&& ~game_over&&(track_timer >= 10'd480); //8 seconds

    wire [9:0]left_train1_top, left_train1_bottom;
    wire [9:0]left_train2_top, left_train2_bottom;
    wire left_train1_active, left_train2_active;

    track left_track(
        .clk(clk),
        .reset(btnD),
        .frame_pulse(frame_pulse),
        .track_enable(left_track_enable),
        .game_over(game_over),
        .random_bits(random_bits),
        .is_middle_track(1'b0),
        .track_id(2'd0),
        .train1_top(left_train1_top),
        .train1_bottom(left_train1_bottom),
        .train1_active(left_train1_active),
        .train2_top(left_train2_top),
        .train2_bottom(left_train2_bottom),
        .train2_active(left_train2_active)
    );

  
    wire [9:0] middle_train1_top, middle_train1_bottom;
    wire [9:0] middle_train2_top, middle_train2_bottom;
    wire middle_train1_active, middle_train2_active;

    track middle_track(
        .clk(clk),
        .reset(btnD),
        .frame_pulse(frame_pulse),
        .track_enable(middle_track_enable),
        .game_over(game_over),
        .random_bits(random_bits),
        .is_middle_track(1'b1),
        .track_id(2'd1),
        .train1_top(middle_train1_top),
        .train1_bottom(middle_train1_bottom),
        .train1_active(middle_train1_active),
        .train2_top(middle_train2_top),
        .train2_bottom(middle_train2_bottom),
        .train2_active(middle_train2_active)
    );

    // Right track
    wire [9:0]right_train1_top, right_train1_bottom;
    wire [9:0]right_train2_top, right_train2_bottom;
    wire right_train1_active, right_train2_active;

    track right_track(
        .clk(clk),
        .reset(btnD),
        .frame_pulse(frame_pulse),
        .track_enable(right_track_enable),
        .game_over(game_over),
        .random_bits(random_bits),
        .is_middle_track(1'b0),
        .track_id(2'd2),
        .train1_top(right_train1_top),
        .train1_bottom(right_train1_bottom),
        .train1_active(right_train1_active),
        .train2_top(right_train2_top),
        .train2_bottom(right_train2_bottom),
        .train2_active(right_train2_active)
    );

    collision_detector collision_det(
        .clk(clk),
        .reset(btnD),
        .game_started(game_started),
        .hovering(hovering),
        .current_track(current_track),
        .left_train1_top(left_train1_top),
        .left_train1_bottom(left_train1_bottom),
        .left_train1_active(left_train1_active),
        .left_train2_top(left_train2_top),
        .left_train2_bottom(left_train2_bottom),
        .left_train2_active(left_train2_active),
        .middle_train1_top(middle_train1_top),
        .middle_train1_bottom(middle_train1_bottom),
        .middle_train1_active(middle_train1_active),
        .middle_train2_top(middle_train2_top),
        .middle_train2_bottom(middle_train2_bottom),
        .middle_train2_active(middle_train2_active),
        .right_train1_top(right_train1_top),
        .right_train1_bottom(right_train1_bottom),
        .right_train1_active(right_train1_active),
        .right_train2_top(right_train2_top),
        .right_train2_bottom(right_train2_bottom),
        .right_train2_active(right_train2_active),
        .collision(collision)
    );

    wire [15:0] score;
    score_manager score_mgr(
        .clk(clk),
        .reset(btnD),
        .frame_pulse(frame_pulse),
        .game_started(game_started),
        .game_over(game_over),
        .left_train1_top(left_train1_top),
        .left_train1_active(left_train1_active),
        .left_train2_top(left_train2_top),
        .left_train2_active(left_train2_active),
        .middle_train1_top(middle_train1_top),
        .middle_train1_active(middle_train1_active),
        .middle_train2_top(middle_train2_top),
        .middle_train2_active(middle_train2_active),
        .right_train1_top(right_train1_top),
        .right_train1_active(right_train1_active),
        .right_train2_top(right_train2_top),
        .right_train2_active(right_train2_active),
        .score(score)
    );

  
    pixel_gen renderer(
        .hcount(hcount),
        .vcount(vcount),
        .active(active),
        .slug_x(slug_x),
        .hovering(hovering),
        .flash(flash_signal),
        .energy_level(energy_level),
        .game_over(game_over),
        .left_train1_top(left_train1_top),
        .left_train1_bottom(left_train1_bottom),
        .left_train1_active(left_train1_active),
        .left_train2_top(left_train2_top),
        .left_train2_bottom(left_train2_bottom),
        .left_train2_active(left_train2_active),
        .middle_train1_top(middle_train1_top),
        .middle_train1_bottom(middle_train1_bottom),
        .middle_train1_active(middle_train1_active),
        .middle_train2_top(middle_train2_top),
        .middle_train2_bottom(middle_train2_bottom),
        .middle_train2_active(middle_train2_active),
        .right_train1_top(right_train1_top),
        .right_train1_bottom(right_train1_bottom),
        .right_train1_active(right_train1_active),
        .right_train2_top(right_train2_top),
        .right_train2_bottom(right_train2_bottom),
        .right_train2_active(right_train2_active),
        .vgaRed(hdmiRed),
        .vgaGreen(hdmiGreen),
        .vgaBlue(hdmiBlue)
    );

    

    wire [3:0] ring;
    ring_counter ring_cnt(
        .clk_i(clk),
        .advance_i(digsel),
        .ring_o(ring)
    );
    
    wire [3:0] digit;
    selector digit_sel(
        .Sel_i(ring),
        .N_i(score),
        .H_o(digit)
    );
    
    hex7seg display(
        .n3(digit[3]),
        .n2(digit[2]),
        .n1(digit[1]),
        .n0(digit[0]),
        .seg(seg)
    );
    
    
    assign an = ~ring; 
    assign dp = 1'b1;  
    
    //hdmi
    assign hdmi_clk = clk;       
    assign hdmi_dispen = active;  
    
endmodule
