module TOP(
	input clk,
	input rst,
	input start,
	input signed [15:0] in_re,
	input signed [15:0] in_im,
	output wire signed [15:0] out_re,
	output wire signed [15:0] out_im,
	output wire done
);

	FFT32 fft32(.clk(clk), .rst(rst), .write_enable(start), .in_re(in_re), .in_im(in_im),
					.out_re(out_re), .out_im(out_im), .done(done));
			
	
	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			//done <= 1'b0;
		end
	end
	
endmodule


	