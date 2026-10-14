//==============================================================
// DAY 11 - TESTBENCH
// 4-BIT UP/DOWN COUNTER
//
// Verification:
//
// LEVEL 1  → Gates
// LEVEL 2  → MUX
// LEVEL 3  → Half Adder
// LEVEL 4  → Full Adder
// LEVEL 5  → 4-bit RCA
// LEVEL 6  → Incrementer
// LEVEL 7  → Decrementer
// LEVEL 8  → Next-State Logic
// LEVEL 9  → DFF
// LEVEL 10 → Register
// LEVEL 11 → Counter
// TOP      → Structural vs RTL
//==============================================================

`timescale 1ns/1ps

module day11_tb;

    integer errors;


    //==========================================================
    // CLOCK
    //==========================================================

    reg clk;

    initial
    begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    //==========================================================
    // LEVEL 1 : GATE TEST SIGNALS
    //==========================================================

    reg A;
    reg B;

    wire NOT_Y;
    wire AND_Y;
    wire OR_Y;
    wire XOR_Y;

    not_gate G1(
        .A(A),
        .Y(NOT_Y)
    );

    and_gate G2(
        .A(A),
        .B(B),
        .Y(AND_Y)
    );

    or_gate G3(
        .A(A),
        .B(B),
        .Y(OR_Y)
    );

    xor_gate G4(
        .A(A),
        .B(B),
        .Y(XOR_Y)
    );


    //==========================================================
    // LEVEL 2 : MUX
    //==========================================================

    reg I0;
    reg I1;
    reg S;

    wire MUX_Y;

    mux_2to1 MUX(
        .I0(I0),
        .I1(I1),
        .S(S),
        .Y(MUX_Y)
    );


    //==========================================================
    // LEVEL 3 : HALF ADDER
    //==========================================================

    reg HA_A;
    reg HA_B;

    wire HA_SUM;
    wire HA_CARRY;

    half_adder HA(
        .A(HA_A),
        .B(HA_B),
        .SUM(HA_SUM),
        .CARRY(HA_CARRY)
    );


    //==========================================================
    // LEVEL 4 : FULL ADDER
    //==========================================================

    reg FA_A;
    reg FA_B;
    reg FA_Cin;

    wire FA_SUM;
    wire FA_COUT;

    full_adder FA(
        .A(FA_A),
        .B(FA_B),
        .Cin(FA_Cin),
        .SUM(FA_SUM),
        .COUT(FA_COUT)
    );


    //==========================================================
    // LEVEL 5 : 4-BIT RCA
    //==========================================================

    reg [3:0] RCA_A;
    reg [3:0] RCA_B;
    reg RCA_Cin;

    wire [3:0] RCA_SUM;
    wire RCA_COUT;

    ripple_carry_adder_4bit RCA(
        .A(RCA_A),
        .B(RCA_B),
        .Cin(RCA_Cin),
        .SUM(RCA_SUM),
        .COUT(RCA_COUT)
    );


    //==========================================================
    // LEVEL 6 : INCREMENTER
    //==========================================================

    reg [3:0] INC_A;

    wire [3:0] INC_Y;
    wire INC_COUT;

    incrementer_4bit INC(
        .A(INC_A),
        .Y(INC_Y),
        .COUT(INC_COUT)
    );


    //==========================================================
    // LEVEL 7 : DECREMENTER
    //==========================================================

    reg [3:0] DEC_A;

    wire [3:0] DEC_Y;
    wire DEC_COUT;

    decrementer_4bit DEC(
        .A(DEC_A),
        .Y(DEC_Y),
        .COUT(DEC_COUT)
    );


    //==========================================================
    // LEVEL 8 : NEXT-STATE LOGIC
    //==========================================================

    reg [3:0] NEXT_Q;
    reg NEXT_UP_DOWN;

    wire [3:0] NEXT_VALUE;

    up_down_next_state NEXT_STATE(
        .Q(NEXT_Q),
        .up_down(NEXT_UP_DOWN),
        .next_Q(NEXT_VALUE)
    );


    //==========================================================
    // LEVEL 9 : DFF TEST
    //==========================================================

    reg reset;

    reg D;

    wire Q_SYNC;
    wire Q_ASYNC;

    dff_sync_reset DFF_SYNC(
        .clk(clk),
        .reset(reset),
        .D(D),
        .Q(Q_SYNC)
    );

    dff_async_reset DFF_ASYNC(
        .clk(clk),
        .reset(reset),
        .D(D),
        .Q(Q_ASYNC)
    );


    //==========================================================
    // LEVEL 10 : REGISTER TEST
    //==========================================================

    reg [3:0] REG_D;

    wire [3:0] REG_SYNC_Q;
    wire [3:0] REG_ASYNC_Q;

    register_4bit_sync REG_SYNC(
        .clk(clk),
        .reset(reset),
        .D(REG_D),
        .Q(REG_SYNC_Q)
    );

    register_4bit_async REG_ASYNC(
        .clk(clk),
        .reset(reset),
        .D(REG_D),
        .Q(REG_ASYNC_Q)
    );


    //==========================================================
    // LEVEL 11 : COUNTER TEST
    //==========================================================

    reg up_down;

    wire [3:0] C_SYNC_STRUCT;
    wire [3:0] C_SYNC_RTL;

    wire [3:0] C_ASYNC_STRUCT;
    wire [3:0] C_ASYNC_RTL;

    up_down_counter_top DUT(
        .clk(clk),
        .reset(reset),
        .up_down(up_down),

        .sync_Q_structural(C_SYNC_STRUCT),
        .sync_Q_rtl(C_SYNC_RTL),

        .async_Q_structural(C_ASYNC_STRUCT),
        .async_Q_rtl(C_ASYNC_RTL)
    );


    //==========================================================
    // TASK : CHECK 1-BIT VALUE
    //==========================================================

    task check_bit;
        input [8*30:1] name;
        input actual;
        input expected;

        begin
            if(actual !== expected)
            begin
                $display("FAIL : %s | Actual=%b Expected=%b",
                         name, actual, expected);
                errors = errors + 1;
            end
            else
                $display("PASS : %s | Value=%b",
                         name, actual);
        end
    endtask


    //==========================================================
    // TASK : CHECK 4-BIT VALUE
    //==========================================================

    task check_4bit;
        input [8*30:1] name;
        input [3:0] actual;
        input [3:0] expected;

        begin
            if(actual !== expected)
            begin
                $display("FAIL : %s | Actual=%b Expected=%b",
                         name, actual, expected);
                errors = errors + 1;
            end
            else
                $display("PASS : %s | Value=%b",
                         name, actual);
        end
    endtask


    //==========================================================
    // LEVEL 1 TEST : BASIC GATES
    //==========================================================

    task test_gates;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 1 : BASIC GATE VERIFICATION");
            $display("==============================================");

            A = 0;
            B = 0;
            #1;

            check_bit("NOT 0", NOT_Y, 1);
            check_bit("AND 00", AND_Y, 0);
            check_bit("OR 00", OR_Y, 0);
            check_bit("XOR 00", XOR_Y, 0);

            A = 0;
            B = 1;
            #1;

            check_bit("NOT 0", NOT_Y, 1);
            check_bit("AND 01", AND_Y, 0);
            check_bit("OR 01", OR_Y, 1);
            check_bit("XOR 01", XOR_Y, 1);

            A = 1;
            B = 0;
            #1;

            check_bit("NOT 1", NOT_Y, 0);
            check_bit("AND 10", AND_Y, 0);
            check_bit("OR 10", OR_Y, 1);
            check_bit("XOR 10", XOR_Y, 1);

            A = 1;
            B = 1;
            #1;

            check_bit("NOT 1", NOT_Y, 0);
            check_bit("AND 11", AND_Y, 1);
            check_bit("OR 11", OR_Y, 1);
            check_bit("XOR 11", XOR_Y, 0);

        end

    endtask


    //==========================================================
    // LEVEL 2 TEST : MUX
    //==========================================================

    task test_mux;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 2 : MUX VERIFICATION");
            $display("==============================================");

            I0 = 0;
            I1 = 1;

            S = 0;
            #1;
            check_bit("MUX S=0", MUX_Y, 0);

            S = 1;
            #1;
            check_bit("MUX S=1", MUX_Y, 1);

        end

    endtask


    //==========================================================
    // LEVEL 3 TEST : HALF ADDER
    //==========================================================

    task test_half_adder;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 3 : HALF ADDER VERIFICATION");
            $display("==============================================");

            HA_A = 0;
            HA_B = 0;
            #1;

            check_bit("HA SUM 00", HA_SUM, 0);
            check_bit("HA CARRY 00", HA_CARRY, 0);

            HA_A = 0;
            HA_B = 1;
            #1;

            check_bit("HA SUM 01", HA_SUM, 1);
            check_bit("HA CARRY 01", HA_CARRY, 0);

            HA_A = 1;
            HA_B = 0;
            #1;

            check_bit("HA SUM 10", HA_SUM, 1);
            check_bit("HA CARRY 10", HA_CARRY, 0);

            HA_A = 1;
            HA_B = 1;
            #1;

            check_bit("HA SUM 11", HA_SUM, 0);
            check_bit("HA CARRY 11", HA_CARRY, 1);

        end

    endtask


    //==========================================================
    // LEVEL 4 TEST : FULL ADDER
    //==========================================================

    task test_full_adder;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 4 : FULL ADDER VERIFICATION");
            $display("==============================================");

            FA_A = 0;
            FA_B = 0;
            FA_Cin = 0;
            #1;

            check_bit("FA 000 SUM", FA_SUM, 0);
            check_bit("FA 000 COUT", FA_COUT, 0);

            FA_A = 0;
            FA_B = 0;
            FA_Cin = 1;
            #1;

            check_bit("FA 001 SUM", FA_SUM, 1);
            check_bit("FA 001 COUT", FA_COUT, 0);

            FA_A = 0;
            FA_B = 1;
            FA_Cin = 1;
            #1;

            check_bit("FA 011 SUM", FA_SUM, 0);
            check_bit("FA 011 COUT", FA_COUT, 1);

            FA_A = 1;
            FA_B = 1;
            FA_Cin = 1;
            #1;

            check_bit("FA 111 SUM", FA_SUM, 1);
            check_bit("FA 111 COUT", FA_COUT, 1);

        end

    endtask


    //==========================================================
    // LEVEL 5 TEST : RCA
    //==========================================================

    task test_rca;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 5 : 4-BIT RCA VERIFICATION");
            $display("==============================================");

            RCA_A = 4'b0011;
            RCA_B = 4'b0010;
            RCA_Cin = 0;
            #1;

            check_4bit("RCA 3+2", RCA_SUM, 4'b0101);
            check_bit("RCA COUT", RCA_COUT, 0);

            RCA_A = 4'b1111;
            RCA_B = 4'b0001;
            RCA_Cin = 0;
            #1;

            check_4bit("RCA 15+1", RCA_SUM, 4'b0000);
            check_bit("RCA COUT", RCA_COUT, 1);

        end

    endtask


    //==========================================================
    // LEVEL 6 TEST : INCREMENTER
    //==========================================================

    task test_incrementer;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 6 : INCREMENTER VERIFICATION");
            $display("==============================================");

            INC_A = 4'b0000;
            #1;
            check_4bit("INC 0", INC_Y, 4'b0001);

            INC_A = 4'b0101;
            #1;
            check_4bit("INC 5", INC_Y, 4'b0110);

            INC_A = 4'b1111;
            #1;
            check_4bit("INC 15", INC_Y, 4'b0000);
            check_bit("INC overflow", INC_COUT, 1);

        end

    endtask


    //==========================================================
    // LEVEL 7 TEST : DECREMENTER
    //==========================================================

    task test_decrementer;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 7 : DECREMENTER VERIFICATION");
            $display("==============================================");

            DEC_A = 4'b0101;
            #1;
            check_4bit("DEC 5", DEC_Y, 4'b0100);

            DEC_A = 4'b0001;
            #1;
            check_4bit("DEC 1", DEC_Y, 4'b0000);

            DEC_A = 4'b0000;
            #1;
            check_4bit("DEC 0", DEC_Y, 4'b1111);

        end

    endtask


    //==========================================================
    // LEVEL 8 TEST : NEXT STATE
    //==========================================================

    task test_next_state;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 8 : UP/DOWN NEXT-STATE VERIFICATION");
            $display("==============================================");

            NEXT_Q = 4'b0101;
            NEXT_UP_DOWN = 1;
            #1;

            check_4bit("NEXT UP 5", NEXT_VALUE, 4'b0110);

            NEXT_Q = 4'b0101;
            NEXT_UP_DOWN = 0;
            #1;

            check_4bit("NEXT DOWN 5", NEXT_VALUE, 4'b0100);

            NEXT_Q = 4'b1111;
            NEXT_UP_DOWN = 1;
            #1;

            check_4bit("UP rollover", NEXT_VALUE, 4'b0000);

            NEXT_Q = 4'b0000;
            NEXT_UP_DOWN = 0;
            #1;

            check_4bit("DOWN underflow", NEXT_VALUE, 4'b1111);

        end

    endtask


    //==========================================================
    // LEVEL 9/10 TEST : DFF + REGISTER
    //==========================================================

    task test_register;

        begin

            $display("");
            $display("==============================================");
            $display("LEVEL 9/10 : DFF + REGISTER VERIFICATION");
            $display("==============================================");

            reset = 1;
            D = 1;
            REG_D = 4'b1010;

            #2;

            // Asynchronous reset acts immediately
            check_bit("ASYNC DFF reset", Q_ASYNC, 0);
            check_4bit("ASYNC register reset",
                       REG_ASYNC_Q,
                       4'b0000);

            // Release reset
            reset = 0;

            // At next positive clock edge, synchronous
            // circuits load data.
            #8;

            check_bit("SYNC DFF load", Q_SYNC, 1);
            check_4bit("SYNC register load",
                       REG_SYNC_Q,
                       4'b1010);

            check_bit("ASYNC DFF load", Q_ASYNC, 1);
            check_4bit("ASYNC register load",
                       REG_ASYNC_Q,
                       4'b1010);

        end

    endtask


    //==========================================================
    // COUNTER TEST : RESET
    //==========================================================

    task test_counter_reset;

        begin

            $display("");
            $display("==============================================");
            $display("COUNTER : RESET VERIFICATION");
            $display("==============================================");

            up_down = 1;
            reset = 1;

            // --------------------------------------------------
            // Asynchronous reset must act immediately.
            // --------------------------------------------------
            #2;

            check_4bit("Counter async reset",
                       C_ASYNC_STRUCT,
                       4'b0000);

            check_4bit("Counter async RTL reset",
                       C_ASYNC_RTL,
                       4'b0000);

            // --------------------------------------------------
            // Synchronous reset must be HIGH at the clock edge.
            // --------------------------------------------------
            @(posedge clk);
            #1;

            check_4bit("Counter sync reset",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("Counter sync RTL reset",
                       C_SYNC_RTL,
                       4'b0000);

            // Release reset. No normal count is checked here;
            // the next test starts from a clean reset state.
            reset = 0;

        end

    endtask


    //==========================================================
    // COUNTER TEST : COUNT UP
    //==========================================================

    task test_count_up;

        integer i;
        reg [3:0] expected;

        begin

            $display("");
            $display("==============================================");
            $display("COUNTER : COUNT UP VERIFICATION");
            $display("==============================================");

            // --------------------------------------------------
            // Make this test independent of previous tests.
            // --------------------------------------------------
            reset = 1;
            up_down = 1;

            @(posedge clk);
            #1;

            check_4bit("UP test reset SYNC",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("UP test reset ASYNC",
                       C_ASYNC_STRUCT,
                       4'b0000);

            reset = 0;
            expected = 4'b0001;

            for(i = 0; i < 8; i = i + 1)
            begin

                @(posedge clk);
                #1;

                check_4bit("SYNC structural UP",
                           C_SYNC_STRUCT,
                           expected);

                check_4bit("SYNC RTL UP",
                           C_SYNC_RTL,
                           expected);

                check_4bit("ASYNC structural UP",
                           C_ASYNC_STRUCT,
                           expected);

                check_4bit("ASYNC RTL UP",
                           C_ASYNC_RTL,
                           expected);

                expected = expected + 1'b1;

            end

        end

    endtask


    //==========================================================
    // COUNTER TEST : COUNT DOWN
    //==========================================================

    task test_count_down;

        integer i;
        reg [3:0] expected;

        begin

            $display("");
            $display("==============================================");
            $display("COUNTER : COUNT DOWN VERIFICATION");
            $display("==============================================");

            // --------------------------------------------------
            // Make this test independent of previous tests.
            // --------------------------------------------------
            reset = 1;
            up_down = 0;

            @(posedge clk);
            #1;

            check_4bit("DOWN test reset SYNC",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("DOWN test reset ASYNC",
                       C_ASYNC_STRUCT,
                       4'b0000);

            reset = 0;

            // First DOWN edge: 0000 - 1 = 1111.
            expected = 4'b1111;

            for(i = 0; i < 8; i = i + 1)
            begin

                @(posedge clk);
                #1;

                check_4bit("SYNC structural DOWN",
                           C_SYNC_STRUCT,
                           expected);

                check_4bit("SYNC RTL DOWN",
                           C_SYNC_RTL,
                           expected);

                check_4bit("ASYNC structural DOWN",
                           C_ASYNC_STRUCT,
                           expected);

                check_4bit("ASYNC RTL DOWN",
                           C_ASYNC_RTL,
                           expected);

                expected = expected - 1'b1;

            end

        end

    endtask


    //==========================================================
    // COUNTER TEST : ROLLOVER
    //==========================================================

    task test_rollover;

        integer i;

        begin

            $display("");
            $display("==============================================");
            $display("COUNTER : ROLLOVER VERIFICATION");
            $display("==============================================");

            // --------------------------------------------------
            // Reset counter to a known state.
            // --------------------------------------------------
            reset = 1;
            up_down = 1;

            @(posedge clk);
            #1;

            check_4bit("Rollover reset SYNC",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("Rollover reset ASYNC",
                       C_ASYNC_STRUCT,
                       4'b0000);

            reset = 0;

            // --------------------------------------------------
            // Count 0 -> 15.
            // --------------------------------------------------
            for(i = 0; i < 15; i = i + 1)
                @(posedge clk);

            #1;

            check_4bit("Before UP rollover",
                       C_SYNC_STRUCT,
                       4'b1111);

            check_4bit("Before UP rollover RTL",
                       C_SYNC_RTL,
                       4'b1111);

            check_4bit("Before UP rollover async",
                       C_ASYNC_STRUCT,
                       4'b1111);

            check_4bit("Before UP rollover async RTL",
                       C_ASYNC_RTL,
                       4'b1111);

            // --------------------------------------------------
            // 1111 + 1 = 0000.
            // --------------------------------------------------
            @(posedge clk);
            #1;

            check_4bit("UP rollover",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("UP rollover RTL",
                       C_SYNC_RTL,
                       4'b0000);

            check_4bit("UP rollover async",
                       C_ASYNC_STRUCT,
                       4'b0000);

            check_4bit("UP rollover async RTL",
                       C_ASYNC_RTL,
                       4'b0000);

        end

    endtask


    //==========================================================
    // COUNTER TEST : UNDERFLOW
    //==========================================================

    task test_underflow;

        begin

            $display("");
            $display("==============================================");
            $display("COUNTER : UNDERFLOW VERIFICATION");
            $display("==============================================");

            // --------------------------------------------------
            // Reset counter to zero.
            // --------------------------------------------------
            reset = 1;
            up_down = 0;

            @(posedge clk);
            #1;

            check_4bit("Underflow reset SYNC",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("Underflow reset RTL",
                       C_SYNC_RTL,
                       4'b0000);

            check_4bit("Underflow reset ASYNC",
                       C_ASYNC_STRUCT,
                       4'b0000);

            check_4bit("Underflow reset async RTL",
                       C_ASYNC_RTL,
                       4'b0000);

            reset = 0;

            // Before the first DOWN clock, Q must still be zero.
            #1;

            check_4bit("Before DOWN underflow",
                       C_SYNC_STRUCT,
                       4'b0000);

            check_4bit("Before DOWN underflow RTL",
                       C_SYNC_RTL,
                       4'b0000);

            // --------------------------------------------------
            // 0000 - 1 = 1111.
            // --------------------------------------------------
            @(posedge clk);
            #1;

            check_4bit("DOWN underflow",
                       C_SYNC_STRUCT,
                       4'b1111);

            check_4bit("DOWN underflow RTL",
                       C_SYNC_RTL,
                       4'b1111);

            check_4bit("DOWN underflow async",
                       C_ASYNC_STRUCT,
                       4'b1111);

            check_4bit("DOWN underflow async RTL",
                       C_ASYNC_RTL,
                       4'b1111);

        end

    endtask


    //==========================================================
    // STRUCTURAL VS RTL COMPARISON
    //==========================================================

    task compare_structural_rtl;

        begin

            $display("");
            $display("==============================================");
            $display("STRUCTURAL VS RTL COMPARISON");
            $display("==============================================");

            if(C_SYNC_STRUCT !== C_SYNC_RTL)
            begin
                $display("FAIL : Sync Structural != Sync RTL");
                errors = errors + 1;
            end
            else
                $display("PASS : Sync Structural == Sync RTL");


            if(C_ASYNC_STRUCT !== C_ASYNC_RTL)
            begin
                $display("FAIL : Async Structural != Async RTL");
                errors = errors + 1;
            end
            else
                $display("PASS : Async Structural == Async RTL");

        end

    endtask


    //==========================================================
    // MAIN TEST
    //==========================================================

    initial
    begin

        errors = 0;

        // Initial values
        A = 0;
        B = 0;

        I0 = 0;
        I1 = 0;
        S = 0;

        HA_A = 0;
        HA_B = 0;

        FA_A = 0;
        FA_B = 0;
        FA_Cin = 0;

        RCA_A = 0;
        RCA_B = 0;
        RCA_Cin = 0;

        INC_A = 0;
        DEC_A = 0;

        NEXT_Q = 0;
        NEXT_UP_DOWN = 0;

        reset = 1;
        D = 0;
        REG_D = 0;

        up_down = 1;


        //======================================================
        // RUN ALL TESTS
        //======================================================

        test_gates();

        test_mux();

        test_half_adder();

        test_full_adder();

        test_rca();

        test_incrementer();

        test_decrementer();

        test_next_state();

        test_register();

        test_counter_reset();

        test_count_up();

        test_count_down();

        test_rollover();

        test_underflow();

        compare_structural_rtl();


        //======================================================
        // FINAL RESULT
        //======================================================

        $display("");
        $display("==================================================");

        if(errors == 0)
        begin
            $display("ALL DAY 11 TESTS PASSED");
            $display("NO VERIFICATION ERRORS");
        end
        else
        begin
            $display("DAY 11 FAILED");
            $display("TOTAL ERRORS = %0d", errors);
        end

        $display("==================================================");

        $finish;

    end


    //==========================================================
    // WAVEFORM DUMP
    //==========================================================

    initial
    begin
        $dumpfile("day11.vcd");
        $dumpvars(0, day11_tb);
    end


endmodule