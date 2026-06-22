`timescale 1ns/1ps

module tb_smart_home_top;

    logic clk, reset;
    logic motion, light_sensor, temp_high, door_open, manual_override;

    logic light, fan, ac, alarm;

    smart_home_top uut (
        .clk(clk),
        .reset(reset),
        .motion(motion),
        .light_sensor(light_sensor),
        .temp_high(temp_high),
        .door_open(door_open),
        .manual_override(manual_override),
        .light(light),
        .fan(fan),
        .ac(ac),
        .alarm(alarm)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_smart_home_top);

        clk = 0;
        reset = 1;

        motion = 0;
        light_sensor = 1;
        temp_high = 0;
        door_open = 0;
        manual_override = 0;

        #10 reset = 0;

        // ACTIVE MODE
        #10 motion = 1; light_sensor = 0;

        // TEMP HIGH
        #20 temp_high = 1;

        // STOP MOTION → TIMER START
        #20 motion = 0;

        // WAIT → ENERGY SAVE
        #120;

        // SECURITY ALERT
        door_open = 1;

        #20;

        // MANUAL MODE
        manual_override = 1;

        #20;

        // BACK TO IDLE
        manual_override = 0;
        door_open = 0;

        #40;

        $finish;
    end

endmodule