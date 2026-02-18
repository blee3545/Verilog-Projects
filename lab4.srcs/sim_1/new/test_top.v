`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2025 06:24:42 AM
// Design Name: 
// Module Name: test_top
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


module test_top();
    reg clkin, btnR, btnC;
    reg [15:0] sw;
    wire [15:0] led;
    wire [6:0] seg;
    wire [3:0] an;
    
    top UUT (
        .clkin(clkin),
        .btnR(btnR),
        .btnC(btnC),
        .sw(sw),
        .seg(seg),
        .led(led),
        .an(an)
    );
    
    wire [3:0] target = UUT.target;
    wire [3:0] current_score = UUT.current_score;
    wire [6:0] state = UUT.game.state;
    
    integer TX_ERROR = 0;
    
    parameter PERIOD = 10;
    parameter real DUTY_CYCLE = 0.5;
    parameter OFFSET = 2;
    
    parameter T_SHORT = 1000;
    parameter T_2SEC = 50000;
    parameter T_4SEC = 90000;
    
    
    initial begin
        #OFFSET clkin = 1'b1;
        forever #(PERIOD-(PERIOD*DUTY_CYCLE)) clkin = ~clkin;
    end
    
    
    initial begin
        
        #2000;
        btnC = 1'b0;
        btnR = 1'b0;
        sw = 16'h0000;
        
        // Reset
        #200;
        btnR = 1'b1;
        #500;
        btnR = 1'b0;
        #1000;
        
        //test 1 win round
        btnC = 1'b1;
        #200;
        btnC = 1'b0;
        #(T_SHORT);
        sw = 16'h0001;
        #(T_2SEC);
        #(T_2SEC);
        sw = 16'h0000;
        #(T_SHORT);
        
        //test 2 lose by wrong switch
        btnC = 1'b1;
        #200;
        btnC = 1'b0;
        #(T_SHORT);
        sw = 16'h0004;
        #(T_4SEC);
        sw = 16'h0000;
        #(T_SHORT);
        
        //test 3 time expires 
        btnC = 1'b1;
        #200;
        btnC = 1'b0;
        #(T_SHORT);
        sw = 16'h0000;
        #(T_2SEC);
        #(T_4SEC);
        
        //test 4 timeout and negative score
        btnC = 1'b1;
        #200;
        btnC = 1'b0;
        #(T_SHORT);
        sw = 16'h0000;
        #(T_2SEC);
        #(T_4SEC);
        
        //test 5, score goes to +4 and win GAMe
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h2000; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0100; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0040; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0008; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0002; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0008; #(T_2SEC); #(T_2SEC); sw = 16'h0000; #(T_SHORT);
        
        #10000;
        
        //reset
        btnR = 1'b1;
        #500;
        btnR = 1'b0;
        #1000;
        
        //test 6 lose game by going to -4
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0010; #(T_4SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0010; #(T_4SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0010; #(T_4SEC); sw = 16'h0000; #(T_SHORT);
        
        btnC = 1'b1; #200; btnC = 1'b0; #(T_SHORT);
        sw = 16'h0010; #(T_4SEC); sw = 16'h0000; #(T_SHORT);
        
        #10000;
        
  
    end
    
endmodule
