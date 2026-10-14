//==============================================================
// DAY 11 - 4-BIT UP/DOWN COUNTER
// Digital VLSI / Verilog RTL Training
//
// Hierarchy:
//
// Gates
//   ↓
// 2:1 MUX
//   ↓
// Half Adder
//   ↓
// Full Adder
//   ↓
// 4-bit Ripple Carry Adder
//   ↓
// Incrementer / Decrementer
//   ↓
// UP/DOWN Next-State Logic
//   ↓
// 4-bit Register
//   ↓
// UP/DOWN Counter
//   ↓
// TOP
//
// Reset versions:
// 1. Synchronous reset
// 2. Asynchronous reset
//
// Verilog-2001
//==============================================================


//==============================================================
// LEVEL 1 : BASIC GATES
//==============================================================

module not_gate(
    input A,
    output Y
);
    assign Y = ~A;
endmodule


module and_gate(
    input A,
    input B,
    output Y
);
    assign Y = A & B;
endmodule


module or_gate(
    input A,
    input B,
    output Y
);
    assign Y = A | B;
endmodule


module xor_gate(
    input A,
    input B,
    output Y
);
    assign Y = A ^ B;
endmodule



//==============================================================
// LEVEL 2 : 2:1 MULTIPLEXER
//
// S = 0 → I0
// S = 1 → I1
//
// Y = S'I0 + SI1
//==============================================================

module mux_2to1(
    input I0,
    input I1,
    input S,
    output Y
);

    wire S_bar;
    wire W0;
    wire W1;

    not_gate U1(
        .A(S),
        .Y(S_bar)
    );

    and_gate U2(
        .A(I0),
        .B(S_bar),
        .Y(W0)
    );

    and_gate U3(
        .A(I1),
        .B(S),
        .Y(W1)
    );

    or_gate U4(
        .A(W0),
        .B(W1),
        .Y(Y)
    );

endmodule



//==============================================================
// LEVEL 3 : HALF ADDER
//
// SUM   = A ^ B
// CARRY = A & B
//==============================================================

module half_adder(
    input A,
    input B,
    output SUM,
    output CARRY
);

    xor_gate U1(
        .A(A),
        .B(B),
        .Y(SUM)
    );

    and_gate U2(
        .A(A),
        .B(B),
        .Y(CARRY)
    );

endmodule



//==============================================================
// LEVEL 4 : FULL ADDER
//
// SUM   = A ^ B ^ Cin
// COUT  = AB + Cin(A^B)
//==============================================================

module full_adder(
    input A,
    input B,
    input Cin,
    output SUM,
    output COUT
);

    wire sum_half;
    wire carry1;
    wire carry2;

    half_adder HA1(
        .A(A),
        .B(B),
        .SUM(sum_half),
        .CARRY(carry1)
    );

    half_adder HA2(
        .A(sum_half),
        .B(Cin),
        .SUM(SUM),
        .CARRY(carry2)
    );

    or_gate OR1(
        .A(carry1),
        .B(carry2),
        .Y(COUT)
    );

endmodule



//==============================================================
// LEVEL 5 : 4-BIT RIPPLE CARRY ADDER
//
// A + B + Cin
//==============================================================

module ripple_carry_adder_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] SUM,
    output COUT
);

    wire C1;
    wire C2;
    wire C3;

    full_adder FA0(
        .A(A[0]),
        .B(B[0]),
        .Cin(Cin),
        .SUM(SUM[0]),
        .COUT(C1)
    );

    full_adder FA1(
        .A(A[1]),
        .B(B[1]),
        .Cin(C1),
        .SUM(SUM[1]),
        .COUT(C2)
    );

    full_adder FA2(
        .A(A[2]),
        .B(B[2]),
        .Cin(C2),
        .SUM(SUM[2]),
        .COUT(C3)
    );

    full_adder FA3(
        .A(A[3]),
        .B(B[3]),
        .Cin(C3),
        .SUM(SUM[3]),
        .COUT(COUT)
    );

endmodule



//==============================================================
// LEVEL 6 : 4-BIT INCREMENTER
//
// A + 1
//==============================================================

module incrementer_4bit(
    input [3:0] A,
    output [3:0] Y,
    output COUT
);

    ripple_carry_adder_4bit RCA(
        .A(A),
        .B(4'b0000),
        .Cin(1'b1),
        .SUM(Y),
        .COUT(COUT)
    );

endmodule



//==============================================================
// LEVEL 7 : 4-BIT DECREMENTER
//
// A - 1
//
// A - 1 = A + 1111
//
// Therefore:
// A + 4'b1111
//
// modulo-16 operation
//==============================================================

module decrementer_4bit(
    input [3:0] A,
    output [3:0] Y,
    output COUT
);

    ripple_carry_adder_4bit RCA(
        .A(A),
        .B(4'b1111),
        .Cin(1'b0),
        .SUM(Y),
        .COUT(COUT)
    );

endmodule



//==============================================================
// LEVEL 8 : UP/DOWN NEXT-STATE LOGIC
//
// up_down = 1 → increment
// up_down = 0 → decrement
//
// Incrementer and decrementer outputs are selected
// using a 4-bit 2:1 MUX.
//==============================================================

module up_down_next_state(
    input [3:0] Q,
    input up_down,
    output [3:0] next_Q
);

    wire [3:0] up_value;
    wire [3:0] down_value;

    wire up_cout;
    wire down_cout;

    // UP path
    incrementer_4bit INC(
        .A(Q),
        .Y(up_value),
        .COUT(up_cout)
    );

    // DOWN path
    decrementer_4bit DEC(
        .A(Q),
        .Y(down_value),
        .COUT(down_cout)
    );

    // Select UP or DOWN
    mux_2to1 MUX0(
        .I0(down_value[0]),
        .I1(up_value[0]),
        .S(up_down),
        .Y(next_Q[0])
    );

    mux_2to1 MUX1(
        .I0(down_value[1]),
        .I1(up_value[1]),
        .S(up_down),
        .Y(next_Q[1])
    );

    mux_2to1 MUX2(
        .I0(down_value[2]),
        .I1(up_value[2]),
        .S(up_down),
        .Y(next_Q[2])
    );

    mux_2to1 MUX3(
        .I0(down_value[3]),
        .I1(up_value[3]),
        .S(up_down),
        .Y(next_Q[3])
    );

endmodule



//==============================================================
// LEVEL 9 : D FLIP-FLOP WITH SYNCHRONOUS RESET
//==============================================================

module dff_sync_reset(
    input clk,
    input reset,
    input D,
    output reg Q
);

    always @(posedge clk)
    begin
        if(reset)
            Q <= 1'b0;
        else
            Q <= D;
    end

endmodule



//==============================================================
// LEVEL 9 : D FLIP-FLOP WITH ASYNCHRONOUS RESET
//==============================================================

module dff_async_reset(
    input clk,
    input reset,
    input D,
    output reg Q
);

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            Q <= 1'b0;
        else
            Q <= D;
    end

endmodule



//==============================================================
// LEVEL 10 : 4-BIT REGISTER WITH SYNCHRONOUS RESET
//==============================================================

module register_4bit_sync(
    input clk,
    input reset,
    input [3:0] D,
    output [3:0] Q
);

    dff_sync_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(D[0]),
        .Q(Q[0])
    );

    dff_sync_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(D[1]),
        .Q(Q[1])
    );

    dff_sync_reset FF2(
        .clk(clk),
        .reset(reset),
        .D(D[2]),
        .Q(Q[2])
    );

    dff_sync_reset FF3(
        .clk(clk),
        .reset(reset),
        .D(D[3]),
        .Q(Q[3])
    );

endmodule



//==============================================================
// LEVEL 10 : 4-BIT REGISTER WITH ASYNCHRONOUS RESET
//==============================================================

module register_4bit_async(
    input clk,
    input reset,
    input [3:0] D,
    output [3:0] Q
);

    dff_async_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(D[0]),
        .Q(Q[0])
    );

    dff_async_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(D[1]),
        .Q(Q[1])
    );

    dff_async_reset FF2(
        .clk(clk),
        .reset(reset),
        .D(D[2]),
        .Q(Q[2])
    );

    dff_async_reset FF3(
        .clk(clk),
        .reset(reset),
        .D(D[3]),
        .Q(Q[3])
    );

endmodule



//==============================================================
// LEVEL 11 : STRUCTURAL UP/DOWN COUNTER
// SYNCHRONOUS RESET
//==============================================================

module up_down_counter_sync_structural(
    input clk,
    input reset,
    input up_down,
    output [3:0] Q
);

    wire [3:0] next_Q;

    up_down_next_state NEXT(
        .Q(Q),
        .up_down(up_down),
        .next_Q(next_Q)
    );

    register_4bit_sync REG(
        .clk(clk),
        .reset(reset),
        .D(next_Q),
        .Q(Q)
    );

endmodule



//==============================================================
// LEVEL 11 : STRUCTURAL UP/DOWN COUNTER
// ASYNCHRONOUS RESET
//==============================================================

module up_down_counter_async_structural(
    input clk,
    input reset,
    input up_down,
    output [3:0] Q
);

    wire [3:0] next_Q;

    up_down_next_state NEXT(
        .Q(Q),
        .up_down(up_down),
        .next_Q(next_Q)
    );

    register_4bit_async REG(
        .clk(clk),
        .reset(reset),
        .D(next_Q),
        .Q(Q)
    );

endmodule



//==============================================================
// RTL VERSION : SYNCHRONOUS RESET
//
// This is the compact behavioral RTL implementation.
//
// Hardware intention:
//
// UP   → Q + 1
// DOWN → Q - 1
//==============================================================

module up_down_counter_sync_rtl(
    input clk,
    input reset,
    input up_down,
    output reg [3:0] Q
);

    always @(posedge clk)
    begin
        if(reset)
            Q <= 4'b0000;

        else if(up_down)
            Q <= Q + 4'b0001;

        else
            Q <= Q - 4'b0001;
    end

endmodule



//==============================================================
// RTL VERSION : ASYNCHRONOUS RESET
//==============================================================

module up_down_counter_async_rtl(
    input clk,
    input reset,
    input up_down,
    output reg [3:0] Q
);

    always @(posedge clk or posedge reset)
    begin
        if(reset)
            Q <= 4'b0000;

        else if(up_down)
            Q <= Q + 4'b0001;

        else
            Q <= Q - 4'b0001;
    end

endmodule



//==============================================================
// TOP MODULE
//
// This top exposes both structural and RTL counters.
//
// sync_Q_structural → structural implementation
// sync_Q_rtl        → behavioral RTL
// async_Q_structural→ structural implementation
// async_Q_rtl       → behavioral RTL
//==============================================================

module up_down_counter_top(
    input clk,
    input reset,
    input up_down,

    output [3:0] sync_Q_structural,
    output [3:0] sync_Q_rtl,

    output [3:0] async_Q_structural,
    output [3:0] async_Q_rtl
);

    up_down_counter_sync_structural U1(
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .Q(sync_Q_structural)
    );

    up_down_counter_sync_rtl U2(
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .Q(sync_Q_rtl)
    );

    up_down_counter_async_structural U3(
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .Q(async_Q_structural)
    );

    up_down_counter_async_rtl U4(
        .clk(clk),
        .reset(reset),
        .up_down(up_down),
        .Q(async_Q_rtl)
    );

endmodule