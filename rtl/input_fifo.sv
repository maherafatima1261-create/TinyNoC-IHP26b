module input_fifo #(
    parameter int DATA_WIDTH = 12,
    parameter int DEPTH      = 4
)(
    input  logic                  clk,
    input  logic                  rst_n,

    input  logic                  wr_en,
    input  logic [DATA_WIDTH-1:0] data_in,

    input  logic                  rd_en,
    output logic [DATA_WIDTH-1:0] data_out,

    output logic                  full,
    output logic                  empty
);

    localparam int PtrWidth = $clog2(DEPTH);

    logic [DATA_WIDTH-1:0] mem [DEPTH];
    logic [PtrWidth-1:0] wr_ptr;
    logic [PtrWidth-1:0] rd_ptr;
    logic [PtrWidth:0] count;

    assign empty = (count == 0);
    assign full  = (count == DEPTH);

    assign data_out = mem[rd_ptr];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= '0;
            rd_ptr <= '0;
            count  <= '0;
        end else begin

            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= wr_ptr + 1'b1;
            end

            if (rd_en && !empty) begin
                rd_ptr <= rd_ptr + 1'b1;
            end

            case ({wr_en && !full, rd_en && !empty})
                2'b10: count <= count + 1'b1;
                2'b01: count <= count - 1'b1;
                default: count <= count;
            endcase

        end
    end

endmodule

