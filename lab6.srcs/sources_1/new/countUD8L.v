`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:36:09 PM
// Design Name: 
// Module Name: countUD8L
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


module countUD8L(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [7:0] Din_i,
    output [7:0] Q_o,
    output utc_o,
    output dtc_o
);
    wire utc0, dtc0;

    countUD4L count_low(
        .clk_i(clk_i),
        .up_i(up_i),
        .dw_i(dw_i),
        .ld_i(ld_i),
        .Din_i(Din_i[3:0]),
        .Q_o(Q_o[3:0]),
        .utc_o(utc0),
        .dtc_o(dtc0)
    );
    countUD4L count_high(
        .clk_i(clk_i),
        .up_i(up_i & utc0),
        .dw_i(dw_i & dtc0),
        .ld_i(ld_i),
        .Din_i(Din_i[7:4]),
        .Q_o(Q_o[7:4]),
        .utc_o(utc_o),
        .dtc_o(dtc_o)
    );

endmodule

//energy counter goes to 192
module energy_counter_8bit(
    input clk_i,
    input up_i,
    input dw_i,
    input ld_i,
    input [7:0] Din_i,
    output [7:0] Q_o,
    output utc_o,
    output dtc_o
);
    // 192 = 0b11000000 = bits [7]=1, [6]=1, [5:0]=0

    wire [7:0]q_next;
    wire [7:0]q_current;

    wire [7:0]q_incremented, q_decremented;
    wire [7:0]after_count;
    wire [7:0]final_value;

    assign q_incremented =q_current + 8'd1;
    assign q_decremented =q_current - 8'd1;

   //increment, decrement, or hold
    assign after_count = ({8{up_i & ~dw_i}} & q_incremented)|({8{dw_i & ~up_i}} & q_decremented)|({8{~up_i & ~dw_i}} & q_current) |({8{up_i & dw_i}}& q_current);  
   
    assign final_value =({8{ld_i}}&Din_i)|({8{~ld_i}} & after_count);

  
    FDRE #(.INIT(1'b0)) ff0(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[0]), .Q(q_current[0]));
    FDRE #(.INIT(1'b0)) ff1(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[1]), .Q(q_current[1]));
    FDRE #(.INIT(1'b0)) ff2(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[2]), .Q(q_current[2]));
    FDRE #(.INIT(1'b0)) ff3(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[3]), .Q(q_current[3]));
    FDRE #(.INIT(1'b0)) ff4(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[4]), .Q(q_current[4]));
    FDRE #(.INIT(1'b0)) ff5(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[5]), .Q(q_current[5]));
    FDRE #(.INIT(1'b1)) ff6(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[6]), .Q(q_current[6]));
    FDRE #(.INIT(1'b1)) ff7(.C(clk_i), .R(1'b0), .CE(1'b1), .D(final_value[7]), .Q(q_current[7])); 

    assign Q_o = q_current;

 
    assign utc_o = &q_current;  
    assign dtc_o = ~(|q_current); 

endmodule