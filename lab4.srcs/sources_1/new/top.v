`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/23/2025 06:02:54 PM
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
    input [15:0] sw,
    input btnC,
    input btnR,
    output[3:0]an,
    output [6:0]seg,
    output[15:0]led
    );
    wire clk, qsec;
    wire [3:0]digsel;

    wire btnC_sync; 
    

    qsec_clks slowit(
        .clkin(clkin),
        .greset(btnR),
        .clk(clk),
        .digsel(digsel),
        .qsec(qsec)
    );

    lfsr rng(
        .clk_i(clk),
        .q_o(lfsr_o)
    );

    

    wire [7:0] lfsr_o;

    //TAKE ONLY LAST 4 BITS OF LSFR OUTPUT for target
    wire[3:0]target;
    wire load_target_o; //change @ GO
    
    wire [15:0] decoded_target; //one hot encoding of targets

    wire [3:0] current_score;
    wire inc_score_o;
    wire dec_score_o;

    wire [5:0]time_count; //quarter seconds
    wire reset_timer_o;
    wire enable_time; //prevent counting during reset

    wire show_target_o; //target visible
    wire flash_score_o; //score flashing
    wire flash_led_o;   //led flashing


    wire four_secs_i; //4 second timer 

    wire win;
    wire lose;
    wire match;
    wire anysw;
    
    wire [15:0]display_number; //selector for which an[3:0]
    wire [3:0] sel_digit;
    wire flash_clock;

    FDRE #(.INIT(1'b0)) btnsync(.C(clk), .R(1'b0), .CE(1'b1), .D(btnC), .Q(btnC_sync)); //this synchronizes btnC to rising edge


    FDRE #(.INIT(1'b0)) t1 (.C(clk), .R(1'b0), .CE(load_target_o), .D(lfsr_o[4]), .Q(target[0]));
    FDRE #(.INIT(1'b0)) t2 (.C(clk), .R(1'b0), .CE(load_target_o), .D(lfsr_o[5]), .Q(target[1]));
    FDRE #(.INIT(1'b0)) t3 (.C(clk), .R(1'b0), .CE(load_target_o), .D(lfsr_o[6]), .Q(target[2])); 
    FDRE #(.INIT(1'b0)) t4 (.C(clk), .R(1'b0), .CE(load_target_o), .D(lfsr_o[7]), .Q(target[3])); //storage for target, this freezes the "spinning" lfsr
    //load_target_go goes high only once per btnC

    decoder dec(
        .in_i(target),
        .out_o(decoded_target)
    );

    assign anysw=sw[15]|sw[14]|sw[13]|sw[12]|sw[11]|sw[10]|sw[9]|sw[8]|sw[7]|sw[6]|sw[5]|sw[4]|sw[3]|sw[2]|sw[1]|sw[0];

   assign match = (sw[0]&decoded_target[0])|
                   (sw[1]&decoded_target[1])|
                   (sw[2]&decoded_target[2])|
                   (sw[3]&decoded_target[3])|
                   (sw[4]&decoded_target[4])|
                   (sw[5]&decoded_target[5])|
                   (sw[6]&decoded_target[6])|
                   (sw[7]&decoded_target[7])|
                   (sw[8]&decoded_target[8])|
                   (sw[9]&decoded_target[9])|
                   (sw[10]&decoded_target[10])|
                   (sw[11]&decoded_target[11])|
                   (sw[12]&decoded_target[12])|
                   (sw[13]&decoded_target[13])|
                   (sw[14]&decoded_target[14])|
                   (sw[15]&decoded_target[15]);

    assign enable_time=qsec&~reset_timer_o; //prevents counting during reset

    time_counter timer(
        .clk_i(clk),
        .inc_i(enable_time),
        .dec_i(1'b0),
        .reset_i(reset_timer_o),
        .din(6'b000000),
        .q_o(time_count)
    );

    assign two_secs_i=~time_count[5]&~time_count[4]&time_count[3]&~time_count[2]&~time_count[1]&~time_count[0]; //2 second timer
    assign four_secs_i=~time_count[5]&time_count[4]&~time_count[3]&~time_count[2]&~time_count[1]&~time_count[0]; //4 second timer

    countUD4L score_counter(
        .clk_i(clk),
        .up_i(inc_score_o),
        .dw_i(dec_score_o),
        .ld_i(1'b0),
        .Din_i(4'b0000),
        .Q_o(current_score),
        .utc_o(),
        .dtc_o()

    );
    
    assign win=~current_score[3]&current_score[2]&~current_score[1]&~current_score[0]; //4 in binary
    assign lose=current_score[3]&current_score[2]&~current_score[1]&~current_score[0]; //-4 in 2s complement

    wire score_is_minus3;
    assign score_is_minus3=current_score[3]&current_score[2]&~current_score[1]&current_score[0]; //-3 in 2s complement (1101)
    
    // Will lose if currently at -4, OR if about to decrement from -3 to -4
    wire will_lose;
    assign will_lose = lose | (score_is_minus3 & dec_score_o);

    wire go_signal; 
    assign go_signal=btnC_sync&~anysw;


    fsm game(
        .clk_i(clk),
        .Go_i(go_signal),
        .anysw_i(anysw),
        .four_secs_i(four_secs_i),
        .two_secs_i(two_secs_i),
        .match_i(match),
        .won_i(win),
        .lost_i(will_lose),
        .load_target_o(load_target_o),
        .reset_timer_o(reset_timer_o),
        .inc_score_o(inc_score_o),
        .dec_score_o(dec_score_o),
        .show_target_o(show_target_o),
        .flash_score_o(flash_score_o),
        .flash_led_o(flash_led_o)
    );

    assign flash_clock=time_count[1]; 

    wire score_is_negative; //one bit wire for neg or not
    wire [3:0] score_magnitude; //score
    wire [3:0] digit_an1; //negative sign digit

    assign score_is_negative=current_score[3]; //MSB shows if its neg or pos

    wire [3:0] score_inverted; //inverted score for 2s complement
    wire[3:0] score_negated;   //negated score for 2s complement
    wire c0, c1, c2; //carry bits for negation

    assign score_inverted=~current_score; //invert bits to 2s complement for hex

    //add 1 to each bit and carry out since cant display this in display
    assign score_negated[0]=score_inverted[0] ^ 1'b1; 
    assign c0=score_inverted[0] & 1'b1;
    assign score_negated[1]=score_inverted[1] ^ c0;
    assign c1=score_inverted[1] & c0;
    assign score_negated[2]=score_inverted[2] ^ c1;
    assign c2=score_inverted[2] & c1;
    assign score_negated[3]=score_inverted[3] ^ c2; 

    //choose what to display based on pos or nrg
    assign score_magnitude[0] = (score_is_negative & score_negated[0]) | (~score_is_negative & current_score[0]);
    assign score_magnitude[1] = (score_is_negative & score_negated[1]) | (~score_is_negative & current_score[1]);
    assign score_magnitude[2] = (score_is_negative & score_negated[2]) | (~score_is_negative & current_score[2]);
    assign score_magnitude[3] = (score_is_negative & score_negated[3]) | (~score_is_negative & current_score[3]); 
    
    mux4bit an1_mux(
        .s(score_is_negative),
        .i0(4'b1111),
        .i1(4'b1110),
        .y(digit_an1)
    );

    wire[3:0] target_display;
    mux4bit target_mux(
        .s(show_target_o),
        .i0(4'b1111),
        .i1(target),
        .y(target_display)
    );


    assign display_number={target_display, 4'b1111, digit_an1, score_magnitude};

    wire[3:0]ring_o;


    ring_counter ring(
        .clk_i(clk),
        .advance_i(digsel),
        .ring_o(ring_o)
    );  

    assign an=~ring_o;

    selector sel(
        .Sel_i(ring_o),
        .N_i(display_number),
        .H_o(sel_digit)
    );

    wire [6:0]seg_normal;
    wire[6:0]seg_hex;
    wire is_minus;
    wire is_blank;

    hex7seg seg7(
        .n3(sel_digit[3]),
        .n2(sel_digit[2]),
        .n1(sel_digit[1]),
        .n0(sel_digit[0]),
        .seg(seg_hex)
    );

    wire [6:0] minus_pattern;
    assign minus_pattern=7'b0111111;

    wire [6:0] blank_pattern;
    assign blank_pattern=7'b1111111;

    assign is_minus=sel_digit[3]&sel_digit[2]&sel_digit[1]&~sel_digit[0] & ring_o[1]; // 14 shows negative


    assign is_blank=sel_digit[3]&sel_digit[2]&sel_digit[1]&sel_digit[0] & (ring_o[2]|(ring_o[1]&~score_is_negative)|(ring_o[3]&~show_target_o)); //turn off displau


    assign seg_normal=({7{is_minus}}&minus_pattern)|({7{is_blank}}&blank_pattern)|({7{~is_minus & ~is_blank}}&seg_hex); //which 7 seg pattern

    wire flash_score_blank;
    // Flash both an[0] (score) and an[1] (minus sign if negative) when flashing score
    assign flash_score_blank=flash_score_o&flash_clock&(ring_o[0]|(ring_o[1]&score_is_negative));


    assign seg=({7{flash_score_blank}}&7'b1111111)|({7{~flash_score_blank}}&seg_normal); //segments off or actual digit pattern

    wire[15:0]led_pattern; 
    wire [15:0] led_flash_mask;

    assign led_pattern=({16{win}} &16'hFFFF)|({16{~win}}&decoded_target);
    assign led_flash_mask={16{flash_clock}}&led_pattern;

    assign led={16{flash_led_o}}&led_flash_mask;



endmodule


