`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/15/2025 07:15:27 PM
// Design Name: 
// Module Name: AddSub4
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

module led_shifter(
    input clk_i, 
    input reset_i, 
    input enable_i, 
    input qsec_i, 
    input dir_i,
    output [7:0] led_o
);
wire[7:0]led;
wire[7:0]next_led;

wire all_off=~(led[7]|led[6]|led[5]|led[4]|led[3]|led[2]|led[1]|led[0]);


wire [7:0] shifted_lr={led[0], led[7:1]};
wire [7:0] shifted_rl={led[6:0], led[7]};

wire[7:0]shifted=({8{~dir_i}}&shifted_lr) |({8{dir_i}}&shifted_rl);

wire [7:0] init_value = ({8{~dir_i}} & 8'b10000000) | ({8{dir_i}} & 8'b00000001);

wire do_init = enable_i & all_off; //init
wire do_shift = enable_i & ~all_off & qsec_i; //shift according to qsec
wire do_hold = enable_i & ~all_off & ~qsec_i; //hold between shifts
wire do_off = ~enable_i; // all off 

//state machine

assign next_led = ({8{do_off}} & 8'b00000000) |({8{do_init}} & init_value) |({8{do_shift}} & shifted) |({8{do_hold}} & led);

FDRE #(.INIT(1'b0)) led_ff0(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[0]), .Q(led[0]));
FDRE #(.INIT(1'b0)) led_ff1(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[1]), .Q(led[1]));
FDRE #(.INIT(1'b0)) led_ff2(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[2]), .Q(led[2]));
FDRE #(.INIT(1'b0)) led_ff3(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[3]), .Q(led[3]));
FDRE #(.INIT(1'b0)) led_ff4(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[4]), .Q(led[4]));
FDRE #(.INIT(1'b0)) led_ff5(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[5]), .Q(led[5]));
FDRE #(.INIT(1'b0)) led_ff6(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[6]), .Q(led[6]));
FDRE #(.INIT(1'b0)) led_ff7(.C(clk_i), .R(reset_i), .CE(1'b1), .D(next_led[7]), .Q(led[7]));

assign led_o=led;

endmodule
