`timescale 1ns/1ps

module route_decode_tb;

    logic [1:0] destination;
    logic [3:0] request;

    int errors = 0;

    route_decode dut (
        .destination (destination),
        .request     (request)
    );

    task automatic check_route(
        input logic [1:0] dest,
        input logic [3:0] expected
    );
        destination = dest;
        #1;

        if (request !== expected) begin
            $display(
                "FAIL: destination=%b expected=%b actual=%b",
                dest,
                expected,
                request
            );
            errors++;
        end else begin
            $display(
                "PASS: destination=%b request=%b",
                dest,
                request
            );
        end
    endtask

    initial begin

        $dumpfile("../sim/route_decode.vcd");
        $dumpvars(0, route_decode_tb);

        check_route(2'b00, 4'b0001);
        check_route(2'b01, 4'b0010);
        check_route(2'b10, 4'b0100);
        check_route(2'b11, 4'b1000);

        if (errors == 0) begin
            $display("===============================");
            $display("ALL ROUTING TESTS PASSED");
            $display("===============================");
        end else begin
            $display("ROUTING TEST FAILED: %0d errors", errors);
        end

        $finish;

    end

endmodule

