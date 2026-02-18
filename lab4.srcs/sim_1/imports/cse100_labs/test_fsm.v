`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench: fsm_tb
// Description: Comprehensive testbench for FSM module
// Tests all scenarios from lab requirements:
// 1. Correct switch - score increments, flashes for 4 seconds total
// 2. Wrong switch - score decrements, LED flashes for 4 seconds
// 3. Timeout (no switch) - score decrements, LED flashes for 4 seconds
// 4. Win condition (score = 4)
// 5. Loss condition (score = -4)
//////////////////////////////////////////////////////////////////////////////////

module fsm_tb();
    // Inputs
    reg clk_i;
    reg go_i;
    reg anysw_i;
    reg four_secs_i;
    reg two_secs_i;
    reg match_i;
    reg won_i;
    reg lost_i;
    
    // Outputs
    wire load_target_o;
    wire reset_timer_o;
    wire inc_score_o;
    wire dec_score_o;
    wire show_target_o;
    wire flash_score_o;
    wire flash_led_o;
    
    // Internal state tracking for verification
    reg [6:0] expected_state;
    wire [6:0] actual_state;
    
    // State definitions (for readability)
    localparam IDLE = 7'b0000001;
    localparam PLAY = 7'b0000010;
    localparam CORRECT = 7'b0000100;
    localparam FLASH_NEW = 7'b0001000;
    localparam WRONG = 7'b0010000;
    localparam WIN = 7'b0100000;
    localparam LOSE = 7'b1000000;
    
    // Instantiate FSM - Fixed port names to match exactly
    fsm uut (
        .clk_i(clk_i),
        .Go_i(go_i),
        .anysw_i(anysw_i),
        .four_secs_i(four_secs_i),
        .two_secs_i(two_secs_i),
        .match_i(match_i),
        .won_i(won_i),
        .lost_i(lost_i),
        .load_target_o(load_target_o),
        .reset_timer_o(reset_timer_o),
        .inc_score_o(inc_score_o),
        .dec_score_o(dec_score_o),
        .show_target_o(show_target_o),
        .flash_score_o(flash_score_o),
        .flash_led_o(flash_led_o)
    );
    
    // Access internal state for verification
    assign actual_state = {uut.state[6], uut.state[5], uut.state[4], uut.state[3], 
                           uut.state[2], uut.state[1], uut.state[0]};
    
    // Clock generation - 10ns period (100MHz)
    initial begin
        clk_i = 0;
        forever #5 clk_i = ~clk_i;
    end
    
    // Test stimulus
    initial begin
        $display("=== FSM Testbench Started ===");
        $display("Time\tState\t\tExpected\tInputs\t\t\tOutputs");
        
        // Initialize all inputs
        go_i = 0;
        anysw_i = 0;
        four_secs_i = 0;
        two_secs_i = 0;
        match_i = 0;
        won_i = 0;
        lost_i = 0;
        expected_state = IDLE;
        
        // Wait for initial state to settle
        #50;
        check_state("Initial IDLE");
        
        // ============================================================
        // TEST 1: Correct Switch Scenario
        // ============================================================
        $display("\n=== TEST 1: CORRECT SWITCH (Score Increment) ===");
        
        // Press Go button to start round
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        expected_state = PLAY;
        #20;
        check_state("After Go - PLAY");
        
        // Wait a bit, then flip correct switch
        #50;
        anysw_i = 1;
        match_i = 1;
        #10;
        expected_state = CORRECT;
        #20;
        check_state("After correct switch - CORRECT");
        
        // Clear switch
        anysw_i = 0;
        match_i = 0;
        
        // Wait for 2 seconds (simulate timer reaching 2 sec)
        #100;
        two_secs_i = 1;
        #10;
        expected_state = FLASH_NEW;
        two_secs_i = 0;
        #20;
        check_state("After 2 sec - FLASH_NEW");
        
        // Wait for another 2 seconds (total 4 seconds)
        #100;
        two_secs_i = 1;
        #10;
        expected_state = IDLE;
        two_secs_i = 0;
        #20;
        check_state("After 4 sec total - Back to IDLE");
        
        // ============================================================
        // TEST 2: Wrong Switch Scenario
        // ============================================================
        $display("\n=== TEST 2: WRONG SWITCH (Score Decrement) ===");
        
        // Press Go button
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        expected_state = PLAY;
        #20;
        check_state("After Go - PLAY");
        
        // Wait a bit, then flip wrong switch
        #50;
        anysw_i = 1;
        match_i = 0;  // Wrong switch!
        #10;
        expected_state = WRONG;
        #20;
        check_state("After wrong switch - WRONG");
        
        // Clear switch
        anysw_i = 0;
        
        // Wait for 4 seconds
        #100;
        four_secs_i = 1;
        #10;
        expected_state = IDLE;
        four_secs_i = 0;
        #20;
        check_state("After 4 sec - Back to IDLE");
        
        // ============================================================
        // TEST 3: Timeout Scenario (No Switch)
        // ============================================================
        $display("\n=== TEST 3: TIMEOUT (No Switch, Score Decrement) ===");
        
        // Press Go button
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        expected_state = PLAY;
        #20;
        check_state("After Go - PLAY");
        
        // Wait for 2 seconds with no switch action
        #100;
        two_secs_i = 1;
        anysw_i = 0;  // No switch flipped
        #10;
        expected_state = WRONG;
        two_secs_i = 0;
        #20;
        check_state("After timeout - WRONG");
        
        // Wait for 4 seconds
        #100;
        four_secs_i = 1;
        #10;
        expected_state = IDLE;
        four_secs_i = 0;
        #20;
        check_state("After 4 sec - Back to IDLE");
        
        // ============================================================
        // TEST 4: Win Scenario (Score = 4)
        // ============================================================
        $display("\n=== TEST 4: WIN CONDITION (Score = 4) ===");
        
        // Press Go button
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        expected_state = PLAY;
        #20;
        
        // Flip correct switch
        #10;
        anysw_i = 1;
        match_i = 1;
        #10;
        expected_state = CORRECT;
        anysw_i = 0;
        match_i = 0;
        #20;
        
        // Wait 2 seconds
        #100;
        two_secs_i = 1;
        #10;
        expected_state = FLASH_NEW;
        two_secs_i = 0;
        #20;
        
        // Wait another 2 seconds WITH won_i = 1
        #100;
        two_secs_i = 1;
        won_i = 1;  // Indicate win condition
        #10;
        expected_state = WIN;
        two_secs_i = 0;
        #20;
        check_state("After winning - WIN state");
        
        // Verify WIN is a terminal state
        #100;
        check_state("Still in WIN (terminal state)");
        
        // Try Go button - should have no effect
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        #20;
        check_state("Go has no effect in WIN state");
        
        won_i = 0;
        
        // ============================================================
        // TEST 5: Loss Scenario (Score = -4)
        // ============================================================
        $display("\n=== TEST 5: LOSS CONDITION (Score = -4) ===");
        
        // Reset to IDLE by forcing state
        #50;
        force uut.ff0.Q = 1'b1;
        force uut.ff1.Q = 1'b0;
        force uut.ff2.Q = 1'b0;
        force uut.ff3.Q = 1'b0;
        force uut.ff4.Q = 1'b0;
        force uut.ff5.Q = 1'b0;
        force uut.ff6.Q = 1'b0;
        #10;
        release uut.ff0.Q;
        release uut.ff1.Q;
        release uut.ff2.Q;
        release uut.ff3.Q;
        release uut.ff4.Q;
        release uut.ff5.Q;
        release uut.ff6.Q;
        expected_state = IDLE;
        #10;
        
        // Press Go button
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        expected_state = PLAY;
        #20;
        
        // Flip wrong switch
        #10;
        anysw_i = 1;
        match_i = 0;
        #10;
        expected_state = WRONG;
        anysw_i = 0;
        #20;
        
        // Wait 4 seconds WITH lost_i = 1
        #100;
        four_secs_i = 1;
        lost_i = 1;  // Indicate loss condition
        #10;
        expected_state = LOSE;
        four_secs_i = 0;
        #20;
        check_state("After losing - LOSE state");
        
        // Verify LOSE is a terminal state
        #100;
        check_state("Still in LOSE (terminal state)");
        
        // Try Go button - should have no effect
        #10;
        go_i = 1;
        #10;
        go_i = 0;
        #20;
        check_state("Go has no effect in LOSE state");
        
        // ============================================================
        // End of tests
        // ============================================================
        #100;
        $display("\n=== All Tests Complete ===");
        $display("Check waveform for detailed timing verification");
        $finish;
    end
    
    // Helper task to check state
    task check_state;
        input [200*8:1] test_name;
        begin
            if (actual_state == expected_state) begin
                $display("%0t\t%s\tPASS: %s", $time, state_name(actual_state), test_name);
            end else begin
                $display("%0t\t%s\tFAIL: %s (Expected: %s)", 
                         $time, state_name(actual_state), test_name, state_name(expected_state));
            end
        end
    endtask
    
    // Helper function to convert state to string
    function [64*8:1] state_name;
        input [6:0] state;
        begin
            case (state)
                IDLE: state_name = "IDLE    ";
                PLAY: state_name = "PLAY    ";
                CORRECT: state_name = "CORRECT ";
                FLASH_NEW: state_name = "FLASH_NEW";
                WRONG: state_name = "WRONG   ";
                WIN: state_name = "WIN     ";
                LOSE: state_name = "LOSE    ";
                default: state_name = "UNKNOWN ";
            endcase
        end
    endfunction

endmodule