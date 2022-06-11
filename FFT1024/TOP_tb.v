`timescale 1ns/1ns
//`define INPUT_FILE "data_in.txt"
`define OUTPUT_FILE "data_out.txt"

module TOP_tb;

	reg clk,rst,start;
	
	reg signed [15:0] in_re;
	reg signed [15:0] in_im;
	wire signed [15:0] out_re;
	wire signed [15:0] out_im;
	wire done;
	
	reg signed [15:0] data_mem[0:2047];
	
	
	integer i,j, fid;
	
	always #5 clk = ~clk;
	
	initial begin
		clk = 0;
		rst = 0;
		start = 0;
		i = 0;
		
		repeat(4) @(posedge clk);
		rst = 1;
		repeat(4) @(posedge clk);
		

		start = 1'b1;
		for(i=0; i<11'd1024; i=i+1) begin
			in_re = 16'd0;
			in_im = 16'd0;
			repeat(1) @(posedge clk);
		end
		repeat(1) @(posedge clk);
		start = 0;
	end
	
	initial begin
		j = 0;
		fid = $fopen("data_out.txt");
		
		wait(done == 1);
		repeat(1) @(posedge clk);
		for(j=0; j<1024; j=j+1) begin
			$fdisplay(fid,"%d %d", out_re, out_im);
			$display("%d %d",out_re,out_im);
			repeat(1) @(posedge clk);
		end
		$display("FFT1024 simulation is over!");
		$fclose(fid);
		$stop;
	end
	
	FFT1024 fft1024(
		.clk(clk),
		.rst(rst),
		.write_enable(start),
		.in_re(in_re),
		.in_im(in_im),
		.out_re(out_re),
		.out_im(out_im),
		.done(done)
	);
	
endmodule
