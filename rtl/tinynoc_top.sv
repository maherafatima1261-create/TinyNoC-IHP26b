module tinynoc_top #(
    parameter int DATA_WIDTH = 12
)(
    input logic clk,
    input logic rst_n,

    // Input Port 0
    input  logic [DATA_WIDTH-1:0] in_packet0,
    input  logic                  in_valid0,
    output logic                  in_ready0,

    // Input Port 1
    input  logic [DATA_WIDTH-1:0] in_packet1,
    input  logic                  in_valid1,
    output logic                  in_ready1,

    // Input Port 2
    input  logic [DATA_WIDTH-1:0] in_packet2,
    input  logic                  in_valid2,
    output logic                  in_ready2,

    // Input Port 3
    input  logic [DATA_WIDTH-1:0] in_packet3,
    input  logic                  in_valid3,
    output logic                  in_ready3,

    // Output Port 0
    output logic [DATA_WIDTH-1:0] out_packet0,
    output logic                  out_valid0,

    // Output Port 1
    output logic [DATA_WIDTH-1:0] out_packet1,
    output logic                  out_valid1,

    // Output Port 2
    output logic [DATA_WIDTH-1:0] out_packet2,
    output logic                  out_valid2,

    // Output Port 3
    output logic [DATA_WIDTH-1:0] out_packet3,
    output logic                  out_valid3
);

    // ------------------------------------------------------------
    // Input FIFO signals
    // ------------------------------------------------------------

    logic [DATA_WIDTH-1:0] fifo_packet0;
    logic [DATA_WIDTH-1:0] fifo_packet1;
    logic [DATA_WIDTH-1:0] fifo_packet2;
    logic [DATA_WIDTH-1:0] fifo_packet3;

    logic fifo_full0;
    logic fifo_full1;
    logic fifo_full2;
    logic fifo_full3;

    logic fifo_empty0;
    logic fifo_empty1;
    logic fifo_empty2;
    logic fifo_empty3;

    logic fifo_rd_en0;
    logic fifo_rd_en1;
    logic fifo_rd_en2;
    logic fifo_rd_en3;

    // Router can accept a packet whenever the corresponding FIFO
    // is not full.
    assign in_ready0 = !fifo_full0;
    assign in_ready1 = !fifo_full1;
    assign in_ready2 = !fifo_full2;
    assign in_ready3 = !fifo_full3;

    // ------------------------------------------------------------
    // Input FIFO 0
    // ------------------------------------------------------------

    input_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (2)
    ) fifo0 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (in_valid0 && in_ready0),
        .data_in  (in_packet0),
        .rd_en    (fifo_rd_en0),
        .data_out (fifo_packet0),
        .full     (fifo_full0),
        .empty    (fifo_empty0)
    );

    // ------------------------------------------------------------
    // Input FIFO 1
    // ------------------------------------------------------------

    input_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (2)
    ) fifo1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (in_valid1 && in_ready1),
        .data_in  (in_packet1),
        .rd_en    (fifo_rd_en1),
        .data_out (fifo_packet1),
        .full     (fifo_full1),
        .empty    (fifo_empty1)
    );

    // ------------------------------------------------------------
    // Input FIFO 2
    // ------------------------------------------------------------

    input_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (2)
    ) fifo2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (in_valid2 && in_ready2),
        .data_in  (in_packet2),
        .rd_en    (fifo_rd_en2),
        .data_out (fifo_packet2),
        .full     (fifo_full2),
        .empty    (fifo_empty2)
    );

    // ------------------------------------------------------------
    // Input FIFO 3
    // ------------------------------------------------------------

    input_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (2)
    ) fifo3 (
        .clk      (clk),
        .rst_n    (rst_n),
        .wr_en    (in_valid3 && in_ready3),
        .data_in  (in_packet3),
        .rd_en    (fifo_rd_en3),
        .data_out (fifo_packet3),
        .full     (fifo_full3),
        .empty    (fifo_empty3)
    );

     // ------------------------------------------------------------
    // Destination extraction and routing requests
    // ------------------------------------------------------------

    logic [1:0] destination0;
    logic [1:0] destination1;
    logic [1:0] destination2;
    logic [1:0] destination3;

    logic [3:0] raw_route_request0;
    logic [3:0] raw_route_request1;
    logic [3:0] raw_route_request2;
    logic [3:0] raw_route_request3;

    logic [3:0] route_request0;
    logic [3:0] route_request1;
    logic [3:0] route_request2;
    logic [3:0] route_request3;

    // Destination is stored in packet bits [11:10].
    assign destination0 = fifo_packet0[11:10];
    assign destination1 = fifo_packet1[11:10];
    assign destination2 = fifo_packet2[11:10];
    assign destination3 = fifo_packet3[11:10];

    route_decode route0 (
        .destination (destination0),
        .request     (raw_route_request0)
    );

    route_decode route1 (
        .destination (destination1),
        .request     (raw_route_request1)
    );

    route_decode route2 (
        .destination (destination2),
        .request     (raw_route_request2)
    );

    route_decode route3 (
        .destination (destination3),
        .request     (raw_route_request3)
    );

    // An empty FIFO must not generate a routing request.
    assign route_request0 = fifo_empty0 ? 4'b0000 : raw_route_request0;
    assign route_request1 = fifo_empty1 ? 4'b0000 : raw_route_request1;
    assign route_request2 = fifo_empty2 ? 4'b0000 : raw_route_request2;
    assign route_request3 = fifo_empty3 ? 4'b0000 : raw_route_request3;

    // ------------------------------------------------------------
    // Output request vectors
    // ------------------------------------------------------------

    logic [3:0] output_request0;
    logic [3:0] output_request1;
    logic [3:0] output_request2;
    logic [3:0] output_request3;

    logic [3:0] qos_vector;

    // Each bit represents one input FIFO requesting that output.
    assign output_request0 = {
        route_request3[0],
        route_request2[0],
        route_request1[0],
        route_request0[0]
    };

    assign output_request1 = {
        route_request3[1],
        route_request2[1],
        route_request1[1],
        route_request0[1]
    };

    assign output_request2 = {
        route_request3[2],
        route_request2[2],
        route_request1[2],
        route_request0[2]
    };

    assign output_request3 = {
        route_request3[3],
        route_request2[3],
        route_request1[3],
        route_request0[3]
    };

    // Packet bit [9] contains the QoS priority bit.
    assign qos_vector = {
        fifo_packet3[9],
        fifo_packet2[9],
        fifo_packet1[9],
        fifo_packet0[9]
    };

    // ------------------------------------------------------------
    // Arbitration grants for each output port
    // ------------------------------------------------------------

    logic [3:0] grant0;
    logic [3:0] grant1;
    logic [3:0] grant2;
    logic [3:0] grant3;

    qos_arbiter arbiter0 (
        .clk          (clk),
        .rst_n        (rst_n),
        .request      (output_request0),
        .qos_priority (qos_vector),
        .grant        (grant0)
    );

    qos_arbiter arbiter1 (
        .clk          (clk),
        .rst_n        (rst_n),
        .request      (output_request1),
        .qos_priority (qos_vector),
        .grant        (grant1)
    );

    qos_arbiter arbiter2 (
        .clk          (clk),
        .rst_n        (rst_n),
        .request      (output_request2),
        .qos_priority (qos_vector),
        .grant        (grant2)
    );

    qos_arbiter arbiter3 (
        .clk          (clk),
        .rst_n        (rst_n),
        .request      (output_request3),
        .qos_priority (qos_vector),
        .grant        (grant3)
    );

    // ------------------------------------------------------------
    // Switch fabrics for each output port
    // ------------------------------------------------------------

    switch_fabric #(
        .DATA_WIDTH(DATA_WIDTH)
    ) switch0 (
        .packet0    (fifo_packet0),
        .packet1    (fifo_packet1),
        .packet2    (fifo_packet2),
        .packet3    (fifo_packet3),
        .grant      (grant0),
        .packet_out (out_packet0),
        .valid_out  (out_valid0)
    );

    switch_fabric #(
        .DATA_WIDTH(DATA_WIDTH)
    ) switch1 (
        .packet0    (fifo_packet0),
        .packet1    (fifo_packet1),
        .packet2    (fifo_packet2),
        .packet3    (fifo_packet3),
        .grant      (grant1),
        .packet_out (out_packet1),
        .valid_out  (out_valid1)
    );

    switch_fabric #(
        .DATA_WIDTH(DATA_WIDTH)
    ) switch2 (
        .packet0    (fifo_packet0),
        .packet1    (fifo_packet1),
        .packet2    (fifo_packet2),
        .packet3    (fifo_packet3),
        .grant      (grant2),
        .packet_out (out_packet2),
        .valid_out  (out_valid2)
    );

    switch_fabric #(
        .DATA_WIDTH(DATA_WIDTH)
    ) switch3 (
        .packet0    (fifo_packet0),
        .packet1    (fifo_packet1),
        .packet2    (fifo_packet2),
        .packet3    (fifo_packet3),
        .grant      (grant3),
        .packet_out (out_packet3),
        .valid_out  (out_valid3)
    );

    // ------------------------------------------------------------
    // FIFO read enables
    // ------------------------------------------------------------
    // An input FIFO is read whenever it wins any output arbitration.

    assign fifo_rd_en0 =
        grant0[0] | grant1[0] | grant2[0] | grant3[0];

    assign fifo_rd_en1 =
        grant0[1] | grant1[1] | grant2[1] | grant3[1];

    assign fifo_rd_en2 =
        grant0[2] | grant1[2] | grant2[2] | grant3[2];

    assign fifo_rd_en3 =
        grant0[3] | grant1[3] | grant2[3] | grant3[3];
endmodule



