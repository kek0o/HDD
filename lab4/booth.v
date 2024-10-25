module booth(
  input wire clk, // global clock signal, 100 MHz frequency
  input wire resetn, // global reset signal, active low
  input wire start, // signal that activates the multiplication process by a rising edge
  input wire ack, // input used to deassert the IRQ and busy outputs
  input wire signed [15:0] data_a, // first 16-bit operand
  input wire signed [15:0] data_b, // second 16-bit operand

  output reg busy, // output that indicates that a multiplication process is in progress
  output reg irq, // irq signal activated when the multiplication has completed
  output reg signed [31:0] result, // result of the multiplication

  input irq_enable // enable for output irq
);

// Registers
reg signed [31:0] partial_res;
reg [2:0] window_count;
wire [1:0] state; // busy, irq
reg start_prev_q;

assign state = {busy,irq};

// signals
wire signed [17:0] action_value;
wire [2:0] window;

////////// detect start positive edge ///////////
wire start_prev_d, start_posedge;
assign start_prev_d = start;

always @(posedge clk) begin
  if (!resetn) start_prev_q <= 1'b0;
  else start_prev_q <= start_prev_d;
end

assign start_posedge = !start_prev_q && start;

////////// CA2 complement //////////////
wire signed [16:0] data_a_comp; // extended 1-bit for worst-case
wire signed [16:0] extended_data_a;
assign extended_data_a = {data_a[15],data_a[15:0]};
assign data_a_comp = ~extended_data_a + 1'b1;

///////////////// 2x multiplicand //////////////////////
wire [17:0] two_data_a, two_data_a_comp;
assign two_data_a = {extended_data_a[16:0], 1'b0}; // 1-bit shift left
assign two_data_a_comp = ~two_data_a + 1'b1;

////////// Radix-4 booth Decoder //////////////
assign window = (window_count == 0) ? {data_b[1:0],1'b0} : data_b[(window_count << 1) + 1 -:3];

assign action_value = (window == 3'b001 || window == 3'b010) ? {extended_data_a[16],extended_data_a} :
                      (window == 3'b011) ? two_data_a :
                      (window == 3'b100) ? two_data_a_comp :
                      (window == 3'b101 || window == 3'b110) ? {data_a_comp[16],data_a_comp} :
                      17'b0;

////////// Partial sum //////////////
wire signed [31:0] partial_sum;
assign partial_sum = partial_res + {action_value,14'b0};

////////// Main sequential logic //////////////
always @(posedge clk) begin
  if (!resetn) begin
    partial_res <= 32'b0;
    window_count <= 3'b0;
    busy <= 1'b0;
    irq <= 1'b0;
  end else begin
    case (state)
      2'b00: begin //idle
        partial_res <= 32'b0;
        if (start_posedge) busy <= 1'b1;
      end
      2'b10: begin // busy
        if (window_count < 7) begin
          partial_res <= {partial_sum[31],partial_sum[31],partial_sum[31:2]}; // 2-bit shift right
          window_count <= window_count + 1'b1;
        end else begin // end of multiplication
          window_count <= 3'b0;
          partial_res <= partial_sum;
          if (irq_enable) irq <= 1'b1;
          else busy <= 1'b0;
        end
      end
      2'b11: begin // irq + busy
        if (ack) begin // wait ack
          irq <= 1'b0;
          busy <= 1'b0;
        end 
      end
    endcase
  end
end

assign result = partial_res;

endmodule
