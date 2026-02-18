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
module top(
    input clkin,
    input btnU,
    input btnL,
    input btnR,
    output [6:0] seg,
    output [3:0] an,
    output [15:0] led
    );
    
    wire clk, qsec, digsel;
    
    lab5_clks slowit (
        .clkin(clkin),
        .greset(btnU),
        .clk(clk),
        .digsel(digsel),
        .qsec(qsec)
    );
    
    //edge detector basically
    wire L_sync, R_sync;
    
    synchronizer sync_l(
        .clk_i(clk),
        .async_i(~btnL),  // Invert: button pressed (0) → sensor blocked (0)
        .sync_o(L_sync)
    );
    
    synchronizer sync_r(
        .clk_i(clk),
        .async_i(~btnR),
        .sync_o(R_sync)
    );
    
   
    wire count_up, count_down, crossing, last_dir;
    
    fsm fsm(
        .clk_i(clk),
        .reset_i(btnU),
        .L_i(L_sync),
        .R_i(R_sync),
        .count_up_o(count_up),
        .count_down_o(count_down),
        .crossing_o(crossing),
        .last_dir_o(last_dir)
    );
    
    // 8-bit up/down counter
    wire [7:0]counter_value;
    
    countUD8L turkey_counter(
        .clk_i(clk),
        .up_i(count_up),
        .dw_i(count_down),
        .ld_i(1'b0),
        .Din_i(8'b00000000),
        .Q_o(counter_value),
        .utc_o(),
        .dtc_o()
    );
    
    // Convert to magnitude and sign
    wire [7:0]magnitude;
    wire is_negative;
    
    twos_complement_8bit converter(
        .value_i(counter_value),
        .magnitude_o(magnitude),
        .sign_o(is_negative)
    );
    
    // LED shifter for direction
    wire [7:0]direction_leds;
    wire shifter_enable;
    
    // shifter is active when not crossing and crossed is at least one
    wire has_crossed;
    FDRE #(.INIT(1'b0)) crossed_ff(
        .C(clk), 
        .R(btnU), 
        .CE(count_up | count_down), 
        .D(1'b1), 
        .Q(has_crossed)
    );
    
    assign shifter_enable=has_crossed&~crossing;
    
    led_shifter shifter(
        .clk_i(clk),
        .reset_i(btnU),
        .enable_i(shifter_enable),
        .qsec_i(qsec),
        .dir_i(last_dir),
        .led_o(direction_leds)
    );
    

    wire [3:0]ring;
    
    ring_counter display_ring(
        .clk_i(clk),
        .advance_i(digsel),
        .ring_o(ring)
    );
    

    wire [3:0]digit;
    wire [3:0]dig0,dig1,dig2,dig3;
    
    assign dig0=magnitude[3:0];
    assign dig1=magnitude[7:4];
    assign dig2=4'b0000;  // For minus sign or blank
    assign dig3=4'b0000;  // Blank
    
    selector display_mux(
        .Sel_i(ring),
        .N_i({dig3, dig2, dig1, dig0}),
        .H_o(digit)
    );
    
    wire [6:0] seg_digit;
    
    hex7seg decoder(
        .n3(digit[3]),
        .n2(digit[2]),
        .n1(digit[1]),
        .n0(digit[0]),
        .seg(seg_digit)
    );
    
    // minus sign to show negative score
    wire [6:0] seg_minus=7'b0111111;  // Only middle segment on
    wire [6:0] seg_blank=7'b1111111;  // All segments off
    
    wire show_minus =is_negative&ring[2];
    wire show_digit=ring[1]|ring[0];
    
    assign seg=({7{show_minus}}&seg_minus) |
                 ({7{show_digit}}&seg_digit) |
                 ({7{~show_minus&~show_digit}} & seg_blank);
    
    assign an=~ring;
    
    
    assign led[7:0]=direction_leds;
    assign led[8]=~R_sync;     // right sensor
    assign led[14:9]=6'b000000;
    assign led[15]=~L_sync;    // left sensor 
    
endmodule