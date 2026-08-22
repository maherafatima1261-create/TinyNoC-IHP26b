module fault_injector #(
    parameter int DATA_WIDTH = 12
)(
    input  logic [DATA_WIDTH-1:0] packet_in,
    input  logic                  fault_enable,
    input  logic [$clog2(DATA_WIDTH)-1:0] fault_bit,
    output logic [DATA_WIDTH-1:0] packet_out
);

    always_comb begin
        packet_out = packet_in;

        if (fault_enable) begin
            packet_out[fault_bit] = ~packet_in[fault_bit];
        end
    end

endmodule

