`timescale 1ns/1ps

module qos_arbiter_tb;

    logic       clk;
    logic       rst_n;
    logic [3:0] request;
    logic [3:0] qos_priority;
    logic [3:0] grant;

    int errors = 0;

    qos_arbiter dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .request      (request),
        .qos_priority (qos_priority),
        .grant        (grant)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    task automatic check_grant(
        input logic [3:0] req,
        input logic [3:0] qos,
        input logic [3:0] expected
    );
        @(negedge clk);
        request      = req;
        qos_priority = qos;

        #1;

        if (grant !== expected) begin
            $display(
                "FAIL: request=%b qos=%b expected=%b actual=%b",
                req, qos, expected, grant
            );
            errors++;
        end else begin
            $display(
                "PASS: request=%b qos=%b grant=%b",
                req, qos, grant
            );
        end
    endtask

    initial begin

        $dumpfile("../sim/qos_arbiter.vcd");
        $dumpvars(0, qos_arbiter_tb);

        request      = 4'b0000;
        qos_priority = 4'b0000;
        rst_n        = 1'b0;

        #20;
        rst_n = 1'b1;

        // High-priority request beats normal-priority request.
        check_grant(
            4'b0011,
            4'b0010,
            4'b0010
        );

        // Inputs 1 and 3 are both high priority.
        // Round-robin fairness should rotate between them.
        check_grant(
            4'b1010,
            4'b1010,
            4'b1000
        );

        check_grant(
            4'b1010,
            4'b1010,
            4'b0010
        );

        // Starvation prevention test.
        // Input 0 = normal priority.
        // Input 1 = high priority.
        // Both keep requesting continuously.
        check_grant(
            4'b0011,
            4'b0010,
            4'b0010
        );

        check_grant(
            4'b0011,
            4'b0010,
            4'b0010
        );

        check_grant(
            4'b0011,
            4'b0010,
            4'b0010
        );

        // After three consecutive high-priority grants,
        // normal-priority Input 0 should get service.
        check_grant(
            4'b0011,
            4'b0010,
            4'b0001
        );

        // No request -> no grant.
        check_grant(
            4'b0000,
            4'b0000,
            4'b0000
        );

        if (errors == 0) begin
            $display("================================");
            $display("ALL QOS ARBITER TESTS PASSED");
            $display("================================");
        end else begin
            $display(
                "QOS ARBITER TEST FAILED: %0d errors",
                errors
            );
        end

        $finish;

    end

endmodule 

