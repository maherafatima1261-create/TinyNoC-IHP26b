`timescale 1ns/1ps

module input_fifo_tb;

    localparam int DataWidth = 12;
    localparam int Depth     = 4;

    logic clk;
    logic rst_n;
    logic wr_en;
    logic [DataWidth-1:0] data_in;
    logic rd_en;
    logic [DataWidth-1:0] data_out;
    logic full;
    logic empty;

    int errors = 0;

    input_fifo #(
        .DATA_WIDTH(DataWidth),
        .DEPTH(Depth)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (wr_en),
        .data_in  (data_in),
        .rd_en    (rd_en),
        .data_out (data_out),
        .full     (full),
        .empty    (empty)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic write_fifo(input logic [DataWidth-1:0] data);
        @(negedge clk);
        wr_en   = 1'b1;
        data_in = data;

        @(negedge clk);
        wr_en = 1'b0;
    endtask

    task automatic read_check(input logic [DataWidth-1:0] expected);
        @(negedge clk);

        if (data_out !== expected) begin
            $display("FAIL: Expected %h, received %h", expected, data_out);
            errors++;
        end else begin
            $display("PASS: Read %h correctly", data_out);
        end

        rd_en = 1'b1;

        @(negedge clk);
        rd_en = 1'b0;
    endtask

    initial begin

        $dumpfile("../sim/input_fifo.vcd");
        $dumpvars(0, input_fifo_tb);

        rst_n   = 1'b0;
        wr_en   = 1'b0;
        rd_en   = 1'b0;
        data_in = '0;

        // RESET TEST
        #20;
        rst_n = 1'b1;

        @(negedge clk);

        if (!empty) begin
            $display("FAIL: FIFO should be empty after reset");
            errors++;
        end else begin
            $display("PASS: Reset test");
        end

        // BASIC FIFO ORDER TEST
        write_fifo(12'hA55);
        write_fifo(12'h3C7);

        read_check(12'hA55);
        read_check(12'h3C7);

        // FULL TEST
        write_fifo(12'h111);
        write_fifo(12'h222);
        write_fifo(12'h333);
        write_fifo(12'h444);

        if (!full) begin
            $display("FAIL: Full flag not asserted");
            errors++;
        end else begin
            $display("PASS: Full flag asserted");
        end

        // OVERFLOW ATTEMPT
        write_fifo(12'h555);

        read_check(12'h111);
        read_check(12'h222);
        read_check(12'h333);
        read_check(12'h444);

        // If overflow protection worked, 555 must not appear.

        // UNDERFLOW ATTEMPT
        @(negedge clk);
        rd_en = 1'b1;

        @(negedge clk);
        rd_en = 1'b0;

        if (!empty) begin
            $display("FAIL: FIFO changed after underflow attempt");
            errors++;
        end else begin
            $display("PASS: Underflow protected");
        end

        // SIMULTANEOUS READ AND WRITE TEST
        write_fifo(12'hABC);

        @(negedge clk);

        if (data_out !== 12'hABC) begin
            $display("FAIL: Simultaneous test initial data incorrect");
            errors++;
        end

        wr_en   = 1'b1;
        rd_en   = 1'b1;
        data_in = 12'hDEF;

        @(negedge clk);
        wr_en = 1'b0;
        rd_en = 1'b0;

        // FIFO should still contain one entry: DEF
        if (empty) begin
            $display("FAIL: FIFO became empty during simultaneous read/write");
            errors++;
        end

        read_check(12'hDEF);

        if (empty) begin
            $display("PASS: Simultaneous read/write test");
        end else begin
            $display("FAIL: FIFO not empty after simultaneous test");
            errors++;
        end

        // FINAL RESULT
        if (errors == 0)
            $display("================================");
        if (errors == 0)
            $display("ALL FIFO TESTS PASSED");
        if (errors == 0)
            $display("================================");
        else
            $display("FIFO TEST FAILED: %0d errors", errors);

        #20;
        $finish;

    end

endmodule
