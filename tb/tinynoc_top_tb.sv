`timescale 1ns/1ps

module tinynoc_top_tb;

    localparam int DataWidth = 12;

    logic clk;
    logic rst_n;

    logic [DataWidth-1:0] in_packet0;
    logic [DataWidth-1:0] in_packet1;
    logic [DataWidth-1:0] in_packet2;
    logic [DataWidth-1:0] in_packet3;

    logic in_valid0;
    logic in_valid1;
    logic in_valid2;
    logic in_valid3;

    logic in_ready0;
    logic in_ready1;
    logic in_ready2;
    logic in_ready3;

    logic [DataWidth-1:0] out_packet0;
    logic [DataWidth-1:0] out_packet1;
    logic [DataWidth-1:0] out_packet2;
    logic [DataWidth-1:0] out_packet3;

    logic out_valid0;
    logic out_valid1;
    logic out_valid2;
    logic out_valid3;

    int errors = 0;

    tinynoc_top #(
        .DATA_WIDTH(DataWidth)
    ) dut (
        .clk         (clk),
        .rst_n       (rst_n),

        .in_packet0  (in_packet0),
        .in_valid0   (in_valid0),
        .in_ready0   (in_ready0),

        .in_packet1  (in_packet1),
        .in_valid1   (in_valid1),
        .in_ready1   (in_ready1),

        .in_packet2  (in_packet2),
        .in_valid2   (in_valid2),
        .in_ready2   (in_ready2),

        .in_packet3  (in_packet3),
        .in_valid3   (in_valid3),
        .in_ready3   (in_ready3),

        .out_packet0 (out_packet0),
        .out_valid0  (out_valid0),

        .out_packet1 (out_packet1),
        .out_valid1  (out_valid1),

        .out_packet2 (out_packet2),
        .out_valid2  (out_valid2),

        .out_packet3 (out_packet3),
        .out_valid3  (out_valid3)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic send_port0(
        input logic [DataWidth-1:0] packet
    );
        @(negedge clk);
        while (!in_ready0)
            @(negedge clk);

        in_packet0 = packet;
        in_valid0  = 1'b1;

        @(negedge clk);
        in_valid0 = 1'b0;
    endtask

    task automatic send_port1(
        input logic [DataWidth-1:0] packet
    );
        @(negedge clk);
        while (!in_ready1)
            @(negedge clk);

        in_packet1 = packet;
        in_valid1  = 1'b1;

        @(negedge clk);
        in_valid1 = 1'b0;
    endtask

    task automatic send_port2(
        input logic [DataWidth-1:0] packet
    );
        @(negedge clk);
        while (!in_ready2)
            @(negedge clk);

        in_packet2 = packet;
        in_valid2  = 1'b1;

        @(negedge clk);
        in_valid2 = 1'b0;
    endtask

    task automatic send_port3(
        input logic [DataWidth-1:0] packet
    );
        @(negedge clk);
        while (!in_ready3)
            @(negedge clk);

        in_packet3 = packet;
        in_valid3  = 1'b1;

        @(negedge clk);
        in_valid3 = 1'b0;
    endtask

    initial begin

        $dumpfile("../sim/tinynoc_top.vcd");
        $dumpvars(0, tinynoc_top_tb);

        rst_n = 1'b0;

        in_packet0 = '0;
        in_packet1 = '0;
        in_packet2 = '0;
        in_packet3 = '0;

        in_valid0 = 1'b0;
        in_valid1 = 1'b0;
        in_valid2 = 1'b0;
        in_valid3 = 1'b0;

        #20;
        rst_n = 1'b1;

        // ------------------------------------------------
        // TEST 1: Input 0 -> Output 2
        // Destination bits [11:10] = 10
        // ------------------------------------------------

        send_port0(12'b10_0_10101010_0);

        #1;

        if (out_valid2 &&
            out_packet2 == 12'b10_0_10101010_0) begin

            $display("PASS: Input 0 routed to Output 2");

        end else begin

            $display("FAIL: Input 0 -> Output 2");
            errors++;

        end

        // ------------------------------------------------
        // TEST 2: Input 1 -> Output 1
        // ------------------------------------------------

        send_port1(12'b01_0_11001100_0);

        #1;

        if (out_valid1 &&
            out_packet1 == 12'b01_0_11001100_0) begin

            $display("PASS: Input 1 routed to Output 1");

        end else begin

            $display("FAIL: Input 1 -> Output 1");
            errors++;

        end

        // ------------------------------------------------
        // TEST 3: Input 3 -> Output 0
        // ------------------------------------------------

        send_port3(12'b00_0_11110000_0);

        #1;

        if (out_valid0 &&
            out_packet0 == 12'b00_0_11110000_0) begin

            $display("PASS: Input 3 routed to Output 0");

        end else begin

            $display("FAIL: Input 3 -> Output 0");
            errors++;

        end

        if (errors == 0) begin
            $display("================================");
            $display("BASIC TINYNOC INTEGRATION PASSED");
            $display("================================");
        end else begin
            $display(
                "TINYNOC INTEGRATION FAILED: %0d errors",
                errors
            );
        end

        #20;
        $finish;

    end

endmodule

