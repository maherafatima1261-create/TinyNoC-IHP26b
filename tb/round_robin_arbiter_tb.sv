`timescale 1ns/1ps

module round_robin_arbiter_tb;

    logic       clk;
    logic       rst_n;
    logic [3:0] request;
    logic [3:0] grant;

    int errors = 0;

    round_robin_arbiter dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .request (request),
        .grant   (grant)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_grant(
        input logic [3:0] req,
        input logic [3:0] expected
    );
        @(negedge clk);
        request = req;

        #1;

        if (grant !== expected) begin
            $display(
                "FAIL: request=%b expected=%b actual=%b",
                req, expected, grant
            );
            errors++;
        end else begin
            $display(
                "PASS: request=%b grant=%b",
                req, grant
            );
        end
    endtask

    initial begin

        $dumpfile("../sim/round_robin_arbiter.vcd");
        $dumpvars(0, round_robin_arbiter_tb);

        request = 4'b0000;
        rst_n   = 1'b0;

        #20;
        rst_n = 1'b1;

        // All four inputs continuously request.
        // After reset, priority begins with Input 0.
        check_grant(4'b1111, 4'b0001);
        check_grant(4'b1111, 4'b0010);
        check_grant(4'b1111, 4'b0100);
        check_grant(4'b1111, 4'b1000);
        check_grant(4'b1111, 4'b0001);

        // Only Input 2 requests.
        check_grant(4'b0100, 4'b0100);

        // Inputs 1 and 3 contend.
        // Previous winner was Input 2, so Input 3 gets priority.
        check_grant(4'b1010, 4'b1000);

        // Same contenders remain.
        // Previous winner was Input 3, so priority wraps and Input 1 wins.
        check_grant(4'b1010, 4'b0010);

        // No requests -> no grant.
        check_grant(4'b0000, 4'b0000);

        if (errors == 0) begin
            $display("================================");
            $display("ALL ROUND-ROBIN TESTS PASSED");
            $display("================================");
        end else begin
            $display(
                "ROUND-ROBIN TEST FAILED: %0d errors",
                errors
            );
        end

        $finish;

    end

endmodule

