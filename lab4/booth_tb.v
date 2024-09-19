`timescale 10ns/1ns

module booth_tb;

reg clk, resetn, start, ack;
reg signed [15:0] data_a;
reg signed [15:0] data_b;

wire busy, irq;
wire signed [31:0] result;

reg irq_enable;

booth uut(clk,resetn,start,ack,data_a,data_b,busy,irq,result,irq_enable);

// clk generation
initial begin
  clk = 1'b1;
  forever #20 clk = ~clk;
end

//task definition
task set_operands(input [15:0] multiplicand, input [15:0] multiplier);
begin
  @(posedge clk);
  #1;
  start = 1'b1;
  data_a = multiplicand;
  data_b = multiplier;
  @(posedge clk);
  #1;
  start = 1'b0;
end
endtask

task wait_ack();
begin
  wait(!busy);
  @(posedge clk);
  #1;
  ack = 1'b1;
  @(posedge clk);
  #1;
  ack = 1'b0;
end
endtask

//stimuli generation
initial begin
  resetn = 1'b1;
  start = 1'b0;
  ack = 1'b0;
  irq_enable = 1'b0;

  #5 resetn = 1'b0;
  @(posedge clk);
  #1 resetn = 1'b1;

  set_operands(2,16);
  wait_ack();
  set_operands(-7,-124);
  wait_ack();
  set_operands(150,-37);
  wait_ack();
  set_operands(-670,2);
  wait_ack();
  set_operands({16{1'b1}},{16{1'b1}});
  wait_ack();
  set_operands({1'b0,{15{1'b1}}},{1'b0,{15{1'b1}}});
  wait_ack();
  set_operands({1'b1,{15'b0}},{1'b1,15'b0});
  wait_ack();
  #500 $finish;
end

initial begin
  $dumpfile("booth_tb.vcd");
  $dumpvars;

end



endmodule
