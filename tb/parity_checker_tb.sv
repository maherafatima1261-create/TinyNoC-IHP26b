`timescale 1ns/1ps

module parity_checker_tb;

    localparam int DataWidth = 12;

    logic [DataWidth-1:0] packet_in;
    logic                 parity_error;

    int errors = 0;

    parity_checker #(
        .DATA_WIDTH(DataWidth)
    ) dut (
        .packet_in    (packet_in),
        .parity_error (parity_error)
    );

    task automatic check_packet(
        input logic [DataWidth-1:0] packet,
        input logic                 expected_error
    );
        packet_in = packet;
        #1;

        if (parity_error !== expected_error) begin
            $display(
                "FAIL: packet=%b expected_error=%b actual_error=%b",
                packet,
                expected_error,
                parity_error
            );
            errors++;
        end else begin
            $display(
                "PASS: packet=%b parity_error=%b",
                packet,
                parity_error
            );
        end
    endtask

    initial begin

        $dumpfile("../sim/parity_checker.vcd");
        $dumpvars(0, parity_checker_tb);

        // Correct even-parity packets
        check_packet(12'b000000000000, 1'b0);
        check_packet(12'b110000000000, 1'b0);
        check_packet(12'b101010101010, 1'b0);

        // Corrupt one bit -> parity error must be detected
        check_packet(12'b000000000001, 1'b1);
        check_packet(12'b110000000001, 1'b1);
        check_packet(12'b101010101011, 1'b1);

        if (errors == 0) begin
            $display("================================");
            $display("ALL PARITY CHECKER TESTS PASSED");
            $display("================================");
        end else begin
            $display("PARITY CHECKER TEST FAILED: %0d errors", errors);
        end

        $finish;

    end

endmodule

