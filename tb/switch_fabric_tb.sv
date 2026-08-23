`timescale 1ns/1ps

module switch_fabric_tb;

    localparam int DataWidth = 12;

    logic [DataWidth-1:0] packet0;
    logic [DataWidth-1:0] packet1;
    logic [DataWidth-1:0] packet2;
    logic [DataWidth-1:0] packet3;

    logic [3:0] grant;

    logic [DataWidth-1:0] packet_out;
    logic                 valid_out;

    int errors = 0;

    switch_fabric #(
        .DATA_WIDTH(DataWidth)
    ) dut (
        .packet0    (packet0),
        .packet1    (packet1),
        .packet2    (packet2),
        .packet3    (packet3),
        .grant      (grant),
        .packet_out (packet_out),
        .valid_out  (valid_out)
    );

    task automatic check_switch(
        input logic [3:0] grant_value,
        input logic [DataWidth-1:0] expected_packet,
        input logic expected_valid
    );

        grant = grant_value;
        #1;

        if ((packet_out !== expected_packet) ||
            (valid_out !== expected_valid)) begin

            $display(
                "FAIL: grant=%b expected_packet=%h actual_packet=%h expected_valid=%b actual_valid=%b",
                grant_value,
                expected_packet,
                packet_out,
                expected_valid,
                valid_out
            );

            errors++;

        end else begin

            $display(
                "PASS: grant=%b packet_out=%h valid=%b",
                grant_value,
                packet_out,
                valid_out
            );

        end
    endtask

    initial begin

        $dumpfile("../sim/switch_fabric.vcd");
        $dumpvars(0, switch_fabric_tb);

        packet0 = 12'h111;
        packet1 = 12'h222;
        packet2 = 12'h333;
        packet3 = 12'h444;

        // No requester selected
        check_switch(4'b0000, 12'h000, 1'b0);

        // Select Input 0
        check_switch(4'b0001, 12'h111, 1'b1);

        // Select Input 1
        check_switch(4'b0010, 12'h222, 1'b1);

        // Select Input 2
        check_switch(4'b0100, 12'h333, 1'b1);

        // Select Input 3
        check_switch(4'b1000, 12'h444, 1'b1);

        // Invalid multi-grant condition
        check_switch(4'b0011, 12'h000, 1'b0);

        if (errors == 0) begin
            $display("================================");
            $display("ALL SWITCH FABRIC TESTS PASSED");
            $display("================================");
        end else begin
            $display(
                "SWITCH FABRIC TEST FAILED: %0d errors",
                errors
            );
        end

        $finish;

    end

endmodule 

