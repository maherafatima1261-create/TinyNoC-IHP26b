module qos_arbiter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] request,
    input  logic [3:0] qos_priority,
    output logic [3:0] grant
);

    logic [3:0] high_request;
    logic [3:0] normal_request;
    logic [3:0] selected_request;

    logic [1:0] high_grant_count;

    assign high_request   = request & qos_priority;
    assign normal_request = request & ~qos_priority;

    always_comb begin
        if ((|high_request) &&
            ((high_grant_count < 2'd3) || !(|normal_request))) begin
            selected_request = high_request;
        end else begin
            selected_request = normal_request;
        end
    end

    round_robin_arbiter rr_arbiter (
        .clk     (clk),
        .rst_n   (rst_n),
        .request (selected_request),
        .grant   (grant)
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            high_grant_count <= 2'd0;
        end else begin
            if ((grant & high_request) != 4'b0000) begin
                if (|normal_request) begin
                    high_grant_count <= high_grant_count + 1'b1;
                end else begin
                    high_grant_count <= 2'd0;
                end
            end else if ((grant & normal_request) != 4'b0000) begin
                high_grant_count <= 2'd0;
            end
        end
    end

endmodule

