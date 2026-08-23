module switch_fabric #(
    parameter int DATA_WIDTH = 12
)(
    input  logic [DATA_WIDTH-1:0] packet0,
    input  logic [DATA_WIDTH-1:0] packet1,
    input  logic [DATA_WIDTH-1:0] packet2,
    input  logic [DATA_WIDTH-1:0] packet3,

    input  logic [3:0] grant,

    output logic [DATA_WIDTH-1:0] packet_out,
    output logic                  valid_out
);

    always_comb begin
        packet_out = '0;
        valid_out  = 1'b0;

        case (grant)
            4'b0001: begin
                packet_out = packet0;
                valid_out  = 1'b1;
            end

            4'b0010: begin
                packet_out = packet1;
                valid_out  = 1'b1;
            end

            4'b0100: begin
                packet_out = packet2;
                valid_out  = 1'b1;
            end

            4'b1000: begin
                packet_out = packet3;
                valid_out  = 1'b1;
            end

            default: begin
                packet_out = '0;
                valid_out  = 1'b0;
            end
        endcase
    end

endmodule

