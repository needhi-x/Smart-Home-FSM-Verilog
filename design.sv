`timescale 1ns/1ps

// ======================================================
// TOP MODULE
// ======================================================
module smart_home_top (
    input  logic clk,
    input  logic reset,

    input  logic motion,
    input  logic light_sensor,
    input  logic temp_high,
    input  logic door_open,
    input  logic manual_override,

    output logic light,
    output logic fan,
    output logic ac,
    output logic alarm
);

    logic [2:0] state;
    logic timer_done;

    // FSM Controller
    fsm_controller u_fsm (
        .clk(clk),
        .reset(reset),
        .motion(motion),
        .door_open(door_open),
        .manual_override(manual_override),
        .timer_done(timer_done),
        .state(state)
    );

    // Timer Module
    timer_counter #(.COUNT_MAX(10)) u_timer (
        .clk(clk),
        .reset(reset),
        .motion(motion),
        .timer_done(timer_done)
    );

    // Output Logic
    output_logic u_out (
        .state(state),
        .motion(motion),
        .light_sensor(light_sensor),
        .temp_high(temp_high),
        .light(light),
        .fan(fan),
        .ac(ac),
        .alarm(alarm)
    );

endmodule


// ======================================================
// FSM CONTROLLER
// ======================================================
module fsm_controller (
    input  logic clk,
    input  logic reset,
    input  logic motion,
    input  logic door_open,
    input  logic manual_override,
    input  logic timer_done,

    output logic [2:0] state
);

    typedef enum logic [2:0] {
        IDLE,
        ACTIVE,
        ENERGY_SAVE,
        SECURITY_ALERT,
        MANUAL_MODE
    } state_t;

    state_t current_state, next_state;

    // Next State Logic
    always_comb begin
        next_state = current_state;

        case (current_state)

            IDLE: begin
                if (manual_override) next_state = MANUAL_MODE;
                else if (door_open) next_state = SECURITY_ALERT;
                else if (motion) next_state = ACTIVE;
            end

            ACTIVE: begin
                if (manual_override) next_state = MANUAL_MODE;
                else if (door_open) next_state = SECURITY_ALERT;
                else if (!motion && timer_done) next_state = ENERGY_SAVE;
            end

            ENERGY_SAVE: begin
                if (manual_override) next_state = MANUAL_MODE;
                else if (door_open) next_state = SECURITY_ALERT;
                else if (motion) next_state = ACTIVE;
            end

            SECURITY_ALERT: begin
                if (manual_override) next_state = MANUAL_MODE;
                else if (!door_open) next_state = IDLE;
            end

            MANUAL_MODE: begin
                if (!manual_override) next_state = IDLE;
            end

            default: next_state = IDLE;

        endcase
    end

    // State Register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    assign state = current_state;

endmodule


// ======================================================
// TIMER MODULE
// ======================================================
module timer_counter #(
    parameter COUNT_MAX = 10
)(
    input  logic clk,
    input  logic reset,
    input  logic motion,

    output logic timer_done
);

    logic [$clog2(COUNT_MAX):0] count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            timer_done <= 0;
        end
        else begin
            if (!motion) begin
                if (count < COUNT_MAX)
                    count <= count + 1;
                else
                    timer_done <= 1;
            end
            else begin
                count <= 0;
                timer_done <= 0;
            end
        end
    end

endmodule


// ======================================================
// OUTPUT LOGIC
// ======================================================
module output_logic (
    input  logic [2:0] state,
    input  logic motion,
    input  logic light_sensor,
    input  logic temp_high,

    output logic light,
    output logic fan,
    output logic ac,
    output logic alarm
);

    typedef enum logic [2:0] {
        IDLE,
        ACTIVE,
        ENERGY_SAVE,
        SECURITY_ALERT,
        MANUAL_MODE
    } state_t;

    always_comb begin
        // Default OFF
        light = 0;
        fan   = 0;
        ac    = 0;
        alarm = 0;

        case (state)

            ACTIVE: begin
                if (motion && !light_sensor)
                    light = 1;

                if (temp_high) begin
                    fan = 1;
                    ac  = 1;
                end
            end

            SECURITY_ALERT: begin
                alarm = 1;
            end

            MANUAL_MODE: begin
                light = 1;
                fan   = 1;
                ac    = 1;
            end

            default: begin
                // IDLE / ENERGY_SAVE → all OFF
            end

        endcase
    end

endmodule