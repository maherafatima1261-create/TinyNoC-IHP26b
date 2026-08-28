module tinynoc_wrapper (
    input  logic [7:0] ui,
    output logic [7:0] uo,
    inout  wire  [7:0] uio
);

    // Use two bidirectional pins as clock/reset inputs
    wire clk   = uio[0];
    wire rst_n = uio[1];

    logic [11:0] packet_reg;
    logic [1:0]  port_sel;
    logic        send_packet;

    logic [11:0] in_packet0, in_packet1, in_packet2, in_packet3;
    logic in_valid0, in_valid1, in_valid2, in_valid3;
    logic in_ready0, in_ready1, in_ready2, in_ready3;

    logic [11:0] out_packet0, out_packet1, out_packet2, out_packet3;
    logic out_valid0, out_valid1, out_valid2, out_valid3;

    /*
     * Simple two-step input protocol:
     *
     * ui[7:0]  = packet data/control
     * uio[3:2] = selected input port
     * uio[4]   = load low byte
     * uio[5]   = load upper 4 bits
     * uio[6]   = send packet
     *
     * uio[7]   = output-port select bit can be extended later.
     */

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            packet_reg <= 12'b0;
            port_sel    <= 2'b0;
        end
        else begin
            port_sel <= uio[3:2];

            if (uio[4])
                packet_reg[7:0] <= ui;

            if (uio[5])
                packet_reg[11:8] <= ui[3:0];
        end
    end

    assign send_packet = uio[6];

    always_comb begin
        in_packet0 = packet_reg;
        in_packet1 = packet_reg;
        in_packet2 = packet_reg;
        in_packet3 = packet_reg;

        in_valid0 = 1'b0;
        in_valid1 = 1'b0;
        in_valid2 = 1'b0;
        in_valid3 = 1'b0;

        if (send_packet) begin
            case (port_sel)
                2'd0: in_valid0 = 1'b1;
                2'd1: in_valid1 = 1'b1;
                2'd2: in_valid2 = 1'b1;
                2'd3: in_valid3 = 1'b1;
            endcase
        end
    end

    // Show output 0 for initial tapeout interface.
    // uo[7:0] carries packet payload.
    always_comb begin
        uo = 8'b0;

        if (out_valid0)
            uo = out_packet0[7:0];
        else if (out_valid1)
            uo = out_packet1[7:0];
        else if (out_valid2)
            uo = out_packet2[7:0];
        else if (out_valid3)
            uo = out_packet3[7:0];
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

