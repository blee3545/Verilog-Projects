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
module vga_counters(
    input clk,
    input reset,
    output [9:0] hcount,
    output [9:0] vcount,
    output frame_tick 
);
    wire [9:0] hcount_next;
    wire [9:0] vcount_next;
    
    wire h_end;
    wire v_end;
    
    assign h_end=(hcount==10'd799);
    wire [9:0]hcount_incremented;
    assign hcount_incremented =hcount+10'd1;
    assign hcount_next=({10{h_end}} & 10'd0)|({10{~h_end}}&hcount_incremented);
    
    assign v_end=(vcount==10'd524);
    wire [9:0]vcount_incremented;
    assign vcount_incremented=vcount+10'd1;
    
    wire [9:0]vcount_if_h_end;
    assign vcount_if_h_end =({10{v_end}}&10'd0)|({10{~v_end}}&vcount_incremented);
    
    assign vcount_next=({10{h_end}} & vcount_if_h_end)|({10{~h_end}}&vcount);
    
    assign frame_tick=(hcount==10'd0)&&(vcount==10'd0);
    
    //horizontal counter
    FDRE #(.INIT(1'b0)) hcount_ff0(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[0]), .Q(hcount[0]));
    FDRE #(.INIT(1'b0)) hcount_ff1(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[1]), .Q(hcount[1]));
    FDRE #(.INIT(1'b0)) hcount_ff2(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[2]), .Q(hcount[2]));
    FDRE #(.INIT(1'b0)) hcount_ff3(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[3]), .Q(hcount[3]));
    FDRE #(.INIT(1'b0)) hcount_ff4(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[4]), .Q(hcount[4]));
    FDRE #(.INIT(1'b0)) hcount_ff5(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[5]), .Q(hcount[5]));
    FDRE #(.INIT(1'b0)) hcount_ff6(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[6]), .Q(hcount[6]));
    FDRE #(.INIT(1'b0)) hcount_ff7(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[7]), .Q(hcount[7]));
    FDRE #(.INIT(1'b0)) hcount_ff8(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[8]), .Q(hcount[8]));
    FDRE #(.INIT(1'b0)) hcount_ff9(.C(clk), .R(reset), .CE(1'b1), .D(hcount_next[9]), .Q(hcount[9]));
    
    //vertical FDREs counter
    FDRE #(.INIT(1'b0)) vcount_ff0(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[0]), .Q(vcount[0]));
    FDRE #(.INIT(1'b0)) vcount_ff1(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[1]), .Q(vcount[1]));
    FDRE #(.INIT(1'b0)) vcount_ff2(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[2]), .Q(vcount[2]));
    FDRE #(.INIT(1'b0)) vcount_ff3(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[3]), .Q(vcount[3]));
    FDRE #(.INIT(1'b0)) vcount_ff4(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[4]), .Q(vcount[4]));
    FDRE #(.INIT(1'b0)) vcount_ff5(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[5]), .Q(vcount[5]));
    FDRE #(.INIT(1'b0)) vcount_ff6(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[6]), .Q(vcount[6]));
    FDRE #(.INIT(1'b0)) vcount_ff7(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[7]), .Q(vcount[7]));
    FDRE #(.INIT(1'b0)) vcount_ff8(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[8]), .Q(vcount[8]));
    FDRE #(.INIT(1'b0)) vcount_ff9(.C(clk), .R(reset), .CE(1'b1), .D(vcount_next[9]), .Q(vcount[9]));
    
endmodule