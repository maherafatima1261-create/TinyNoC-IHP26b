module round_robin_arbiter (
    input  logic       clk,
    input  logic       rst_n,
    input  logic [3:0] request,
    output logic [3:0] grant
);

    logic [1:0] last_grant;

    always_comb begin
        grant = 4'b0000;

        case (last_grant)

            2'd0: begin
                if      (request[1]) grant = 4'b0010;
                else if (request[2]) grant = 4'b0100;
                else if (request[3]) grant = 4'b1000;
                else if (request[0]) grant = 4'b0001;
            end

            2'd1: begin
                if      (request[2]) grant = 4'b0100;
                else if (request[3]) grant = 4'b1000;
                else if (request[0]) grant = 4'b0001;
                else if (request[1]) grant = 4'b0010;
            end

            2'd2: begin
                if      (request[3]) grant = 4'b1000;
                else if (request[0]) grant = 4'b0001;
                else if (request[1]) grant = 4'b0010;
                else if (request[2]) grant = 4'b0100;
            end

            default: begin
                if      (request[0]) grant = 4'b0001;
                else if (request[1]) grant = 4'b0010;
                else if (request[2]) grant = 4'b0100;
                else if (request[3]) grant = 4'b1000;
            end

        endcase
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            last_grant <= 2'd3;
        end else begin
            case (grant)
                4'b0001: last_grant <= 2'd0;
                4'b0010: last_grant <= 2'd1;
                4'b0100: last_grant <= 2'd2;
                4'b1000: last_grant <= 2'd3;
                default: last_grant <= last_grant;
            endcase
        end
    end

endmodule

