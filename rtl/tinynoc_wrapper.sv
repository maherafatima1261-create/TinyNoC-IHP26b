module tinynoc_wrapper (
    input  wire [7:0] ui_in,
    output logic [7:0] uo_out,

    input  wire [7:0] uio_in,
    output logic [7:0] uio_out,
    output logic [7:0] uio_oe,

    input  wire ena,
    input  wire clk,
    input  wire rst_n
);

    logic [11:0] packet_reg;
    logic [1:0]  port_sel;

    logic [11:0] in_packet0, in_packet1, in_packet2, in_packet3;
    logic in_valid0, in_valid1, in_valid2, in_valid3;
    logic in_ready0, in_ready1, in_ready2, in_ready3;

    logic [11:0] out_packet0, out_packet1, out_packet2, out_packet3;
    logic out_valid0, out_valid1, out_valid2, out_valid3;

    /*
     * Input protocol
     *
     * ui_in[7:0] : packet data
     *
     * uio_in[1:0] : TinyNoC input-port select
     * uio_in[2]   : load packet bits [7:0]
     * uio_in[3]   : load packet bits [11:8]
     * uio_in[4]   : send packet
     *
     * uio_in[7:5] currently unused
     */

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            packet_reg <= 12'b0;
            port_sel    <= 2'b0;
        end
        else if (ena) begin
            port_sel <= uio_in[1:0];

            if (uio_in[2])
                packet_reg[7:0] <= ui_in;

            if (uio_in[3])
                packet_reg[11:8] <= ui_in[3:0];
        end
    end

    always_comb begin
        in_packet0 = packet_reg;
        in_packet1 = packet_reg;
        in_packet2 = packet_reg;
        in_packet3 = packet_reg;

        in_valid0 = 1'b0;
        in_valid1 = 1'b0;
        in_valid2 = 1'b0;
        in_valid3 = 1'b0;

        if (ena && uio_in[4]) begin
            case (port_sel)
                2'd0: in_valid0 = 1'b1;
                2'd1: in_valid1 = 1'b1;
                2'd2: in_valid2 = 1'b1;
                2'd3: in_valid3 = 1'b1;
            endcase
        end
    end

    /*
     * Output protocol
     *
     * uo_out = lower 8 bits of whichever output currently has valid data.
     * uio_out[3:0] = packet upper nibble.
     * uio_out[5:4] = output-port number.
     * uio_out[6]   = output valid.
     */

    always_comb begin
        uo_out  = 8'b0;
        uio_out = 8'b0;
        uio_oe  = 8'hF0;

        if (out_valid0) begin
            uo_out       = out_packet0[7:0];
            uio_out[3:0] = out_packet0[11:8];
            uio_out[5:4] = 2'd0;
            uio_out[6]   = 1'b1;
        end
        else if (out_valid1) begin
            uo_out       = out_packet1[7:0];
            uio_out[3:0] = out_packet1[11:8];
            uio_out[5:4] = 2'd1;
            uio_out[6]   = 1'b1;
        end
        else if (out_valid2) begin
            uo_out       = out_packet2[7:0];
            uio_out[3:0] = out_packet2[11:8];
            uio_out[5:4] = 2'd2;
            uio_out[6]   = 1'b1;
        end
        else if (out_valid3) begin
            uo_out       = out_packet3[7:0];
            uio_out[3:0] = out_packet3[11:8];
            uio_out[5:4] = 2'd3;
            uio_out[6]   = 1'b1;
        end
    end

    tinynoc_top #(
        .DATA_WIDTH(12)
    ) core (
        .clk(clk),
        .rst_n(rst_n),

        .in_packet0(in_packet0),
        .in_valid0(in_valid0),
        .in_ready0(in_ready0),

        .in_packet1(in_packet1),
        .in_valid1(in_valid1),
        .in_ready1(in_ready1),

        .in_packet2(in_packet2),
        .in_valid2(in_valid2),
        .in_ready2(in_ready2),

        .in_packet3(in_packet3),
        .in_valid3(in_valid3),
        .in_ready3(in_ready3),

        .out_packet0(out_packet0),
        .out_valid0(out_valid0),

        .out_packet1(out_packet1),
        .out_valid1(out_valid1),

        .out_packet2(out_packet2),
        .out_valid2(out_valid2),

        .out_packet3(out_packet3),
        .out_valid3(out_valid3)
    );

endmodule

