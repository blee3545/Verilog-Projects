`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 07:14:18 PM
// Design Name: 
// Module Name: countUD4L
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


module countUD4L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i, 
    input [3:0] Din_i, 
    output [3:0]Q_o,
    output utc_o,
    output dtc_o
    );
    wire [3:0] q_inadd;
    wire [3:0] q_insub;
    wire[3:0] q_infinal;
    
     //added value
    AddSub4 add (.A_i(Q_o), .B_i(4'b0001), .sub_i(1'b0), .S_o(q_inadd),.cout_o());
    
    //subtracted value
    AddSub4 subtract (.A_i(Q_o), .B_i(4'b0001), .sub_i(1'b1), .S_o(q_insub),.cout_o());
    
    wire[3:0] addorno; //mux between hold or add
    mux4bit upmux(.s(up_i), .i0(Q_o), .i1(q_inadd), .y(addorno));
    
    wire [3:0] after_dw; //mux between addorno or subtracted
    mux4bit dwmux(.s(dw_i), .i0(addorno), .i1(q_insub), .y(after_dw));
     
    mux4bit ldmux(.s(ld_i), .i0(after_dw), .i1(Din_i), .y(q_infinal)); //choose between count or load
    
    FDRE #(.INIT(1'b0)) ff0(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_infinal[0]), .Q(Q_o[0]));
    FDRE #(.INIT(1'b0)) ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_infinal[1]), .Q(Q_o[1]));
    FDRE #(.INIT(1'b0)) ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_infinal[2]), .Q(Q_o[2]));
    FDRE #(.INIT(1'b0)) ff3(.C(clk_i), .R(1'b0), .CE(1'b1), .D(q_infinal[3]), .Q(Q_o[3]));
    
    assign utc_o=Q_o[3]&Q_o[2]&Q_o[1]&Q_o[0];
    assign dtc_o=~Q_o[3]&~Q_o[2]&~Q_o[1]&~Q_o[0];


    
endmodule

module countUD16L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i, 
    input [15:0] Din_i, 
    output [15:0]Q_o,
    output utc_o,
    output dtc_o
    );
    
    wire utc0, utc1, utc2,utc3;
    wire dtc0,dtc1,dtc2,dtc3;
    
    countUD4L count0( 
    .clk_i(clk_i), 
    .up_i(up_i), 
    .dw_i(dw_i), 
    .ld_i(ld_i), 
    .Din_i(Din_i[3:0]), 
    .Q_o(Q_o[3:0]), 
    .utc_o(utc0), 
    .dtc_o(dtc0)
    );
    
    countUD4L count1( 
    .clk_i(clk_i), 
    .up_i(up_i &utc0), 
    .dw_i(dw_i&dtc0), 
    .ld_i(ld_i), 
    .Din_i(Din_i[7:4]), 
    .Q_o(Q_o[7:4]), 
    .utc_o(utc1), 
    .dtc_o(dtc1)
    );
    
    countUD4L count2( 
    .clk_i(clk_i), 
    .up_i(up_i &utc0&utc1), 
    .dw_i(dw_i&dtc0&dtc1), 
    .ld_i(ld_i), 
    .Din_i(Din_i[11:8]), 
    .Q_o(Q_o[11:8]), 
    .utc_o(utc2), 
    .dtc_o(dtc2)
    );
    
    
    
    countUD4L count3( 
    .clk_i(clk_i), 
    .up_i(up_i &utc0&utc1&utc2), 
    .dw_i(dw_i&dtc0&dtc1&dtc2), 
    .ld_i(ld_i), 
    .Din_i(Din_i[15:12]), 
    .Q_o(Q_o[15:12]), 
    .utc_o(utc3), 
    .dtc_o(dtc3)
    );
    
    assign utc_o=Q_o[15]&Q_o[15]&Q_o[14]&Q_o[13]&Q_o[12]&Q_o[11]&Q_o[10]&Q_o[9]&Q_o[8]&Q_o[7]&Q_o[6]&Q_o[5]&Q_o[4]&Q_o[3]&Q_o[2]&Q_o[1]&Q_o[0];
    assign dtc_o=~Q_o[15]&~Q_o[15]&~Q_o[14]&~Q_o[13]&~Q_o[12]&~Q_o[11]&~Q_o[10]&~Q_o[9]&~Q_o[8]&~Q_o[7]&~Q_o[6]&~Q_o[5]&~Q_o[4]&~Q_o[3]&~Q_o[2]&~Q_o[1]&~Q_o[0];
    
    
    
endmodule
