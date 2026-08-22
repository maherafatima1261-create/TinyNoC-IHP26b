module route_decode (
    input  logic [1:0] destination,
    output logic [3:0] request
);

    always_comb begin
        case (destination)
            2'b00: request = 4'b0001;
            2'b01: request = 4'b0010;
            2'b10: request = 4'b0100;
            2'b11: request = 4'b1000;
            default: request = 4'b0000;
        endcase
    end

endmodule

