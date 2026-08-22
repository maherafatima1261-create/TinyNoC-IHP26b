`timescale 1ns/1ps

module fault_injector_tb;

    localparam int DataWidth = 12;

    logic [DataWidth-1:0] packet_in;
    logic                 fault_enable;
    logic [$clog2(DataWidth)-1:0] fault_bit;

    logic [DataWidth-1:0] packet_out;
    logic                 parity_error;

    int errors = 0;

    fault_injector #(
        .DATA_WIDTH(DataWidth)
    ) dut_fault (
        .packet_in    (packet_in),
        .fault_enable (fault_enable),
        .fault_bit    (fault_bit),
        .packet_out   (packet_out)
    );

    parity_checker #(
        .DATA_WIDTH(DataWidth)
    ) dut_parity (
        .packet_in    (packet_out),
        .parity_error (parity_error)
    );

    initial begin

        $dumpfile("../sim/fault_injector.vcd");
        $dumpvars(0, fault_injector_tb);

        // Valid even-parity packet
        packet_in    = 12'b101010101010;
        fault_enable = 1'b0;
        fault_bit    = '0;

        #1;

        if (packet_out !== packet_in || parity_error !== 1'b0) begin
            $display("FAIL: Normal pass-through test");
            errors++;
        end else begin
            $display("PASS: Normal pass-through test");
        end

        // Inject fault at bit 0
        fault_enable = 1'b1;
        fault_bit    = 0;

        #1;

        if (packet_out !== 12'b101010101011 ||
            parity_error !== 1'b1) begin
            $display("FAIL: Bit-0 fault detection");
            errors++;
        end else begin
            $display("PASS: Bit-0 fault detected");
        end

        // Inject fault at bit 5
        fault_bit = 5;

        #1;

        if (packet_out !== (packet_in ^ 12'b000000100000) ||
            parity_error !== 1'b1) begin
            $display("FAIL: Bit-5 fault detection");
            errors++;
        end else begin
            $display("PASS: Bit-5 fault detected");
        end

        // Inject fault at bit 11
        fault_bit = 11;

        #1;

        if (packet_out !== (packet_in ^ 12'b100000000000) ||
            parity_error !== 1'b1) begin
            $display("FAIL: Bit-11 fault detection");
            errors++;
        end else begin
            $display("PASS: Bit-11 fault detected");
        end

        if (errors == 0) begin
            $display("================================");
            $display("ALL FAULT INJECTION TESTS PASSED");
            $display("================================");
        end else begin
            $display("FAULT INJECTOR TEST FAILED: %0d errors", errors);
        end

        $finish;

    end

endmodule

