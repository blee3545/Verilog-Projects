`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2025 09:27:30 AM
// Design Name:
// Module Name: collision_detector
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

module collision_detector(
    input clk,
    input reset,
    input game_started,
    input hovering,
    input [1:0]current_track,
   
    // left
    input [9:0]left_train1_top,
    input [9:0]left_train1_bottom,
    input left_train1_active,
    input [9:0]left_train2_top,
    input [9:0]left_train2_bottom,
    input left_train2_active,
    // middle
    input [9:0]middle_train1_top,
    input [9:0]middle_train1_bottom,
    input middle_train1_active,
    input [9:0]middle_train2_top,
    input [9:0]middle_train2_bottom,
    input middle_train2_active,
    // right
    input [9:0]right_train1_top,
    input [9:0]right_train1_bottom,
    input right_train1_active,
    input [9:0]right_train2_top,
    input [9:0]right_train2_bottom,
    input right_train2_active,
    output collision
);

    // rows for slug positioning
    wire [9:0] slug_top; 
    wire [9:0] slug_bottom;
    assign slug_top = 10'd360;
    assign slug_bottom = 10'd375;  

    // track wires
    wire [1:0] track_left;
    wire [1:0] track_middle;
    wire [1:0] track_right;
    assign track_left = 2'b00;
    assign track_middle = 2'b01;
    assign track_right = 2'b10;

    ///train overlap with slugs
    wire left1_overlap, left2_overlap;
    wire middle1_overlap, middle2_overlap;
    wire right1_overlap, right2_overlap;

    // left track colisions
    wire on_left_track;
    assign on_left_track =(current_track==track_left);

    assign left1_overlap =left_train1_active&&on_left_track&& ~hovering &&(left_train1_bottom >= slug_top)&&(left_train1_top<=slug_bottom);

    assign left2_overlap=left_train2_active&&on_left_track &&~hovering&&(left_train2_bottom>=slug_top) &&(left_train2_top<=slug_bottom);

    //middle track collisions
    wire on_middle_track;
    assign on_middle_track =(current_track == track_middle);

    assign middle1_overlap=middle_train1_active&&on_middle_track&& ~hovering&&(middle_train1_bottom>=slug_top) &&(middle_train1_top <= slug_bottom);

    assign middle2_overlap = middle_train2_active && on_middle_track && ~hovering &&(middle_train2_bottom >= slug_top) &&(middle_train2_top <= slug_bottom);

    //right track
    wire on_right_track;
    assign on_right_track =(current_track == track_right);

    assign right1_overlap= right_train1_active&&on_right_track&& ~hovering &&(right_train1_bottom >= slug_top)&&(right_train1_top <= slug_bottom);

    assign right2_overlap =right_train2_active && on_right_track&& ~hovering&&(right_train2_bottom>=slug_top)&&(right_train2_top<=slug_bottom);

    //if there is an overlap, that means the slug hit a train 
    wire any_overlap;
    assign any_overlap = left1_overlap||left2_overlap||middle1_overlap ||middle2_overlap||right1_overlap ||right2_overlap;

    assign collision =game_started&&any_overlap;

endmodule
