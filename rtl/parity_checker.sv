module parity_checker #(
    parameter int DATA_WIDTH = 12
)(
    input  logic [DATA_WIDTH-1:0] packet_in,
    output logic                  parity_error
);

    always_comb begin
        parity_error = ^packet_in;
    end

endmodule

