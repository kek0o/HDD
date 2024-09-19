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

reg [2:0] window;
reg[2:0] window_count;
reg [1:0] state;
reg prev;

always @(posedge clk) begin
  if (!resetn) begin
    busy <= 1'b0;
    irq <= 1'b0;
    result <= 32'b0;
    partial_res <= 32'b0;
    prev <= 1'b0;
    window_count <= 0;
    window <= 3'b0;
    state  <= 2'b00;
  end else begin
    case (state)
      2'b00: begin // idle
        if (start) begin
          busy <= 1'b1;
          window <= {data_b[1:0], prev};
          state <= 2'b01;
        end
      end
      2'b01: begin // mult
        case (window) // actions for the radix-4 booth multiplier
          3'b000: partial_res <= partial_res;
          3'b001: partial_res <= partial_res + data_a;
          3'b010: partial_res <= partial_res + data_a;
          3'b011: partial_res <= partial_res + (data_a << 1);
          3'b100: partial_res <= partial_res - (data_a << 1);
          3'b101: partial_res <= partial_res - data_a;
          3'b110: partial_res <= partial_res - data_a;
          3'b111: partial_res <= partial_res;
        endcase

        if (window_count == 7) begin // 
          result <= partial_res;
          window_count <= 2'b0;
          prev <= 1'b0;
          irq <= irq_enable ? 1'b1 : 1'b0;
          state <= 2'b10;
        end else begin
          data_b <= data_b >>> 2;
          prev <= data_b[1];
          window_count <= window_count + 1'b1;
          state <= 2'b11; // new window + shift
        end
      end
      2'b10: begin // done
        if (irq_enable) begin
          if (ack) begin
            irq <= 1'b0;
            busy <= 1'b0;
            state <= 2'b00;
          end else state <= 2'b10;
        end else begin
          busy <= 1'b0; 
          state <= 2'b00;
        end
        partial_res <= 32'b0;
      end
      2'b11: begin // new window + shift
        window <= {data_b[1:0], prev};
        data_a <= data_a <<< 2*window_count;
        state <= 2'b01;
      end
    endcase
  end
end

endmodule
