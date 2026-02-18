`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/18/2025 09:27:41 AM
// Design Name:
// Module Name: score_manager
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


module score_manager(
    input clk,
    input reset,
    input frame_pulse,
    input game_started,
    input game_over,
    input [9:0] left_train1_top,
    input left_train1_active,
    input [9:0] left_train2_top,
    input left_train2_active,
    input [9:0] middle_train1_top,
    input middle_train1_active,
    input [9:0] middle_train2_top,
    input middle_train2_active,
    input [9:0] right_train1_top,
    input right_train1_active,
    input [9:0] right_train2_top,
    input right_train2_active,
    output [15:0] score
);

    //scroing slug
    wire [9:0] slug_row;
    wire [9:0] score_row;
    assign slug_row = 10'd360;
    assign score_row = 10'd376; 
    wire left1_at_row, left2_at_row;
    wire middle1_at_row, middle2_at_row;
    wire right1_at_row, right2_at_row;

    //checks if trains are at a place to score
    assign left1_at_row=left_train1_active &&game_started&&~game_over&&(left_train1_top == score_row);
    assign left2_at_row=left_train2_active && game_started && ~game_over&&(left_train2_top == score_row);
    assign middle1_at_row =middle_train1_active&&game_started &&~game_over&&(middle_train1_top == score_row);
    assign middle2_at_row=middle_train2_active &&game_started&&~game_over&&(middle_train2_top == score_row);
    assign right1_at_row=right_train1_active &&game_started&&~game_over&&(right_train1_top == score_row);
    assign right2_at_row =right_train2_active&&game_started&&~game_over&&(right_train2_top == score_row);

    //train counter
    wire [2:0] trains_at_row;
    wire [15:0] score_increment;

    assign trains_at_row = {2'b00, left1_at_row} + {2'b00, left2_at_row} +{2'b00, middle1_at_row} + {2'b00, middle2_at_row} +{2'b00, right1_at_row} + {2'b00, right2_at_row};

    assign score_increment={{13{1'b0}}, trains_at_row};

    //score counter
    wire [15:0] score_reg;
    wire [15:0] score_next;
    wire [15:0] score_incremented;

    // any_at_row is high when at least one train is at the score row
    wire any_at_row;
    assign any_at_row =left1_at_row|left2_at_row|middle1_at_row|middle2_at_row|right1_at_row|right2_at_row;

    assign score_incremented = score_reg + score_increment;
    // only update score on frame_pulse when trains are at score row
    assign score_next = ({16{frame_pulse && any_at_row}} & score_incremented)|({16{~(frame_pulse && any_at_row)}} & score_reg);

    // score flip flop
    FDRE #(.INIT(1'b0)) score_ff0(.C(clk), .R(reset), .CE(1'b1), .D(score_next[0]), .Q(score_reg[0]));
    FDRE #(.INIT(1'b0)) score_ff1(.C(clk), .R(reset), .CE(1'b1), .D(score_next[1]), .Q(score_reg[1]));
    FDRE #(.INIT(1'b0)) score_ff2(.C(clk), .R(reset), .CE(1'b1), .D(score_next[2]), .Q(score_reg[2]));
    FDRE #(.INIT(1'b0)) score_ff3(.C(clk), .R(reset), .CE(1'b1), .D(score_next[3]), .Q(score_reg[3]));
    FDRE #(.INIT(1'b0)) score_ff4(.C(clk), .R(reset), .CE(1'b1), .D(score_next[4]), .Q(score_reg[4]));
    FDRE #(.INIT(1'b0)) score_ff5(.C(clk), .R(reset), .CE(1'b1), .D(score_next[5]), .Q(score_reg[5]));
    FDRE #(.INIT(1'b0)) score_ff6(.C(clk), .R(reset), .CE(1'b1), .D(score_next[6]), .Q(score_reg[6]));
    FDRE #(.INIT(1'b0)) score_ff7(.C(clk), .R(reset), .CE(1'b1), .D(score_next[7]), .Q(score_reg[7]));
    FDRE #(.INIT(1'b0)) score_ff8(.C(clk), .R(reset), .CE(1'b1), .D(score_next[8]), .Q(score_reg[8]));
    FDRE #(.INIT(1'b0)) score_ff9(.C(clk), .R(reset), .CE(1'b1), .D(score_next[9]), .Q(score_reg[9]));
    FDRE #(.INIT(1'b0)) score_ff10(.C(clk), .R(reset), .CE(1'b1), .D(score_next[10]), .Q(score_reg[10]));
    FDRE #(.INIT(1'b0)) score_ff11(.C(clk), .R(reset), .CE(1'b1), .D(score_next[11]), .Q(score_reg[11]));
    FDRE #(.INIT(1'b0)) score_ff12(.C(clk), .R(reset), .CE(1'b1), .D(score_next[12]), .Q(score_reg[12]));
    FDRE #(.INIT(1'b0)) score_ff13(.C(clk), .R(reset), .CE(1'b1), .D(score_next[13]), .Q(score_reg[13]));
    FDRE #(.INIT(1'b0)) score_ff14(.C(clk), .R(reset), .CE(1'b1), .D(score_next[14]), .Q(score_reg[14]));
    FDRE #(.INIT(1'b0)) score_ff15(.C(clk), .R(reset), .CE(1'b1), .D(score_next[15]), .Q(score_reg[15]));

    assign score = score_reg;

endmodule
