module booth(
input wire clk, // global clock signal, 100 MHz frequency
input wire resetn, // global reset signal, active low
input wire start, // signal that activates the multiplication process by a rising edge
input wire ack, // input used to deassert the IRQ and busy outputs
input wire [15:0] data_a, // first 16-bit operand
input wire [15:0] data_b, // second 16-bit operand

output reg busy, // output that indicates that a multiplication process is in progress
output reg irq, // irq signal activated when the multiplication has completed
output reg signed [31:0] result, // result of the multiplication

input irq_enable // enable for output irq
);

reg signed [31:0] partial_res;
reg[3:0] window_count;
reg state;
reg [2:0] window;

assign window = partial_res[2:0];
assign busy = state;
always @(posedge clk) begin
  if (!resetn) begin
    irq <= 1'b0;
    partial_res <= 32'b0;
    window_count <= 4'b0;
    state <= 1'b0;
  end else begin
    case (state)
      1'b0: begin //idle
        if (start) begin
          partial_res <= {15'b0, data_b, 1'b0};
          state <= 1'b1;
        end
      end
      1'b1: begin // busy
        if (window_count < 8) begin
          case (partial_res[2:0]) // radix-4 booth multiplier decoder
            3'b001: partial_res = (partial_res + {data_a,16'b0}); // + data_a
            3'b010: partial_res = (partial_res + {data_a,16'b0}); // +data_a
            3'b011: partial_res = (partial_res + ({data_a <<< 1,16'b0})); // +2*data_a
            3'b100: partial_res = (partial_res - ({data_a <<< 1,16'b0})); // -2*data_a
            3'b101: partial_res = (partial_res - {data_a, 16'b0}); // -data_a
            3'b110: partial_res = (partial_res - {data_a,16'b0}); // -data_a
            default: partial_res = partial_res;
          endcase
          partial_res <= partial_res >>> 2; // 2-bit shift right
          window_count <= window_count + 1'b1;
        end else begin
          if (irq_enable) begin
            if (!ack) irq <= 1'b1;
            else begin
              irq <= 1'b0;
              window_count <= 4'b0;
              state <= 1'b0;
            end
          end else begin
            window_count <= 4'b0;
            state <= 1'b0;
          end
        end
      end
    endcase
  end
end

always @(negedge clk) begin
  if (!resetn) result = partial_res;
  else begin
    if (window_count == 8) begin
      result = partial_res;
      irq <= irq_enable;
    end
  end
end

endmodule
