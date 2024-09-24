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

// registers
reg signed [31:0] partial_res;
reg[2:0] window_count;
reg [1:0] state;
reg start_prev_q;

// wires
wire [2:0] window;
wire start_prev_d, start_posedge;

assign window = partial_res[2:0]; // multiplicand bits to inspect (initially partial_res[15:0] = data_b)

assign busy = state[1];
assign irq = irq_enable ? state[0] : 1'b0;

// detect start positive edge
assign start_prev_d = start;
assign start_posedge = !start_prev_q && start;

always @(posedge clk) begin
  if (!resetn) start_prev_q <= 1'b0;
  else start_prev_q <= start_prev_d;
end

// radix-4 booth algorithm decoder
always @(*) begin
  if (state == 2'b10) begin
    case (window) // radix-4 booth multiplier decoder
      3'b001: partial_res = (partial_res + {data_a,16'b0}); // + data_a
      3'b010: partial_res = (partial_res + {data_a,16'b0}); // +data_a
      3'b011: partial_res = (partial_res + ({data_a <<< 1,16'b0})); // +2*data_a
      3'b100: partial_res = (partial_res - ({data_a <<< 1,16'b0})); // -2*data_a
      3'b101: partial_res = (partial_res - {data_a, 16'b0}); // -data_a
      3'b110: partial_res = (partial_res - {data_a,16'b0}); // -data_a
      default: partial_res = partial_res;
   endcase
  end
end

// main sequential logic
always @(posedge clk) begin
  if (!resetn) begin
    partial_res <= 32'b0;
    window_count <= 3'b0;
    state <= 2'b00;
  end else begin
    case (state)
      2'b00: begin // idle
        if (start_posedge) begin
          partial_res <= {15'b0, data_b, 1'b0};
          state <= 2'b10;
        end
      end
      2'b10: begin // busy
        partial_res <= partial_res >>> 2; // 2-bit shift right
        if (window_count < 7) window_count <= window_count + 1'b1;
        else begin // end of multiplier
          window_count <= 3'b0;
          result <= partial_res >>> 2;
          state <= 2'b11;
        end
      end
      2'b11: begin // done
        if (irq_enable) begin // wait ack
          if (ack) state <= 2'b00;
          else state <= 2'b11;
        end else state <= 2'b00;
      end
    endcase
  end
end

endmodule
