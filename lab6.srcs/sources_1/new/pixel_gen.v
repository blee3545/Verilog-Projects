`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2025 07:36:09 PM
// Design Name: 
// Module Name: pixel_gen
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


module pixel_gen(
    input [9:0]hcount,
    input [9:0]vcount,
    input active,
    input [9:0]slug_x,
    input hovering,
    input flash,
    input [7:0]energy_level,
    input game_over,
    input [9:0]left_train1_top,
    input [9:0]left_train1_bottom,
    input left_train1_active,
    input [9:0]left_train2_top,
    input [9:0]left_train2_bottom,
    input left_train2_active,
    input [9:0]middle_train1_top,
    input [9:0]middle_train1_bottom,
    input middle_train1_active,
    input [9:0]middle_train2_top,
    input [9:0]middle_train2_bottom,
    input middle_train2_active,
    input [9:0]right_train1_top,
    input [9:0]right_train1_bottom,
    input right_train1_active,
    input [9:0]right_train2_top,
    input [9:0]right_train2_bottom,
    input right_train2_active,
    output [3:0]vgaRed,
    output [3:0]vgaGreen,
    output [3:0]vgaBlue
);
    wire [3:0]pixel_red;
    wire [3:0]pixel_green;
    wire [3:0]pixel_blue; //wires for color in window

    // Check if in border
    wire in_border;
    assign in_border=active&&((hcount < 10'd8)||(hcount >= 10'd632)||(vcount < 10'd8)||(vcount >= 10'd472));
    
    // check if in energy bar
    // 20 pixels wide and 192 tall
    wire [9:0]energy_bar_bottom;
    wire [9:0]energy_bar_top;
    wire [9:0]energy_height;

    assign energy_bar_bottom=10'd264;  
    assign energy_height={{2{1'b0}}, energy_level}; 
    assign energy_bar_top =energy_bar_bottom-energy_height;

    wire in_energy_bar;
    assign in_energy_bar =active &&(hcount >= 10'd16)&&(hcount <= 10'd35)&&(vcount >= energy_bar_top)&&(vcount <= energy_bar_bottom);  
    
    //in slug?
    wire [9:0] slug_right, slug_bottom;
    assign slug_right =slug_x + 10'd15;   
    assign slug_bottom =10'd375;     
    
    wire in_slug_area;
    assign in_slug_area =active &&(hcount>=slug_x) &&(hcount<=slug_right)&&(vcount>=10'd360) &&(vcount <= slug_bottom);

    //visibility
    wire slug_visible;
    assign slug_visible =({1{game_over}} &flash)|({1{~game_over & hovering}}&flash)|({1{~game_over& ~hovering}} & 1'b1);

    wire in_slug;
    assign in_slug =in_slug_area && slug_visible;

    //track spacing
    wire [9:0] left_track_left, left_track_right;
    wire [9:0] middle_track_left, middle_track_right;
    wire [9:0] right_track_left, right_track_right;

    assign left_track_left =10'd238;
    assign left_track_right =10'd297; 

    assign middle_track_left =10'd307; 
    assign middle_track_right =10'd366;

    assign right_track_left =10'd376;  
    assign right_track_right =10'd435;

    // in left train tracks
    wire in_left_train1, in_left_train2;
    assign in_left_train1= active&&left_train1_active&&(hcount>=left_track_left)&&(hcount<=left_track_right)&&(vcount>=left_train1_top) &&(vcount <= left_train1_bottom);

    assign in_left_train2 =active&&left_train2_active&&(hcount >=left_track_left)&&(hcount<=left_track_right) &&(vcount>= left_train2_top)&&(vcount <= left_train2_bottom);

    // in middle
    wire in_middle_train1, in_middle_train2;
    assign in_middle_train1=active && middle_train1_active&&(hcount >= middle_track_left)&&(hcount<=middle_track_right)&&(vcount >= middle_train1_top) &&(vcount <= middle_train1_bottom);

    assign in_middle_train2 = active && middle_train2_active &&(hcount>= middle_track_left)&&(hcount <= middle_track_right) &&(vcount >= middle_train2_top) &&(vcount <= middle_train2_bottom);

    // Check if in right track trains
    wire in_right_train1, in_right_train2;
    assign in_right_train1= active &&right_train1_active&&(hcount >= right_track_left)&&(hcount <= right_track_right)&&(vcount >= right_train1_top) &&(vcount <= right_train1_bottom);

    assign in_right_train2 = active && right_train2_active &&(hcount>= right_track_left)&&(hcount <=right_track_right)&&(vcount >= right_train2_top) &&(vcount <= right_train2_bottom);

    wire in_any_train;
    assign in_any_train = in_left_train1||in_left_train2||in_middle_train1 ||in_middle_train2||in_right_train1 || in_right_train2;

    //color for slugs, train, energy bar, border, and background

    // 
    wire [3:0] red_if_border, red_if_train, red_if_energy, red_if_bg;
    assign red_if_border =4'hF;
    assign red_if_train =4'h0;  
    assign red_if_energy =4'h0;
    assign red_if_bg =4'h0;
    
    // slug colors
    wire [3:0] slug_red_game_over, slug_red_hover, slug_red_idle;
    assign slug_red_game_over =4'hF;  // game over
    assign slug_red_hover =4'h0;      //hovering
    assign slug_red_idle =4'hF;       //idle
    wire [3:0] red_slug_color;
    assign red_slug_color =({4{game_over}} & slug_red_game_over)|({4{~game_over & hovering}} & slug_red_hover)|({4{~game_over & ~hovering}} & slug_red_idle);
    
    assign pixel_red = ({4{in_border}} & red_if_border) |({4{in_slug & ~in_border}} & red_slug_color) |
                      ({4{in_any_train & ~in_border & ~in_slug}} & red_if_train) |
                      ({4{in_energy_bar & ~in_border & ~in_slug & ~in_any_train}} & red_if_energy) |
                      ({4{~in_border & ~in_slug & ~in_any_train & ~in_energy_bar}} & red_if_bg);
    
    //green
    wire [3:0] green_if_border, green_if_train, green_if_energy, green_if_bg;
    assign green_if_border = 4'hF;
    assign green_if_train = 4'h0;  
    assign green_if_energy = 4'hF;
    assign green_if_bg = 4'h0;

    // slug green color selector
    wire [3:0] slug_green_game_over, slug_green_hover, slug_green_idle;
    assign slug_green_game_over = 4'hF;  
    assign slug_green_hover = 4'hF;      
    assign slug_green_idle = 4'hF;       
    wire [3:0] green_slug_color;
    assign green_slug_color = ({4{game_over}} & slug_green_game_over) |
                             ({4{~game_over & hovering}} & slug_green_hover) |
                             ({4{~game_over & ~hovering}} & slug_green_idle);

    assign pixel_green = ({4{in_border}} & green_if_border) |
                        ({4{in_slug & ~in_border}} & green_slug_color) |
                        ({4{in_any_train & ~in_border & ~in_slug}} & green_if_train) |
                        ({4{in_energy_bar & ~in_border & ~in_slug & ~in_any_train}} & green_if_energy) |
                        ({4{~in_border & ~in_slug & ~in_any_train & ~in_energy_bar}} & green_if_bg);
    
    // blue
    wire [3:0] blue_if_border, blue_if_train, blue_if_energy, blue_if_bg;
    assign blue_if_border = 4'hF;
    assign blue_if_train = 4'hF;   
    assign blue_if_energy = 4'h0;
    assign blue_if_bg = 4'h0;

   
    wire [3:0] slug_blue_game_over, slug_blue_hover, slug_blue_idle;
    assign slug_blue_game_over = 4'h0; 
    assign slug_blue_hover = 4'hF;    
    assign slug_blue_idle = 4'h0;       
    wire [3:0] blue_slug_color;
    assign blue_slug_color = ({4{game_over}} & slug_blue_game_over) |
                            ({4{~game_over & hovering}} & slug_blue_hover) |
                            ({4{~game_over & ~hovering}} & slug_blue_idle);

    assign pixel_blue = ({4{in_border}} & blue_if_border) |
                       ({4{in_slug & ~in_border}} & blue_slug_color) |
                       ({4{in_any_train & ~in_border & ~in_slug}} & blue_if_train) |
                       ({4{in_energy_bar & ~in_border & ~in_slug & ~in_any_train}} & blue_if_energy) |
                       ({4{~in_border & ~in_slug & ~in_any_train & ~in_energy_bar}} & blue_if_bg);
    
    assign vgaRed = ({4{active}} & pixel_red) | ({4{~active}} & 4'h0);
    assign vgaGreen = ({4{active}} & pixel_green) | ({4{~active}} & 4'h0);
    assign vgaBlue = ({4{active}} & pixel_blue) | ({4{~active}} & 4'h0);
    
endmodule
