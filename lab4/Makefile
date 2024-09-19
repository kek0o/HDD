TB ?= booth_tb

all: wave

tb.vvp: $(TB).v
	iverilog -g2012 -o $(TB).vvp -c compile_files.txt 
run: tb.vvp
	vvp $(TB).vvp 

wave: run
	surfer $(TB).vcd

clean: 
	rm -f $(TB).vvp
	rm -f $(TB).vcd
