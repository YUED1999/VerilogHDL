module BTN_IN(
	input clk,
	input rst,
	input bin,
	output reg bout
);

	//50MHzを1250000分周して40Hzをつくる
	//en40hzはシステムクロック1周期分のパルスで40Hz
	reg [20:0] cnt;
	
	wire en40hz = (cnt==1250000 - 1);
	
	always @(posedge clk) begin
		if(~rst)
			cnt <= 21'b0;
		else if(en40hz) begin
			cnt <= 21'b0;
			bout <= bin;
		end
		else
			cnt <= cnt + 21'b1;
	end
	
	/*
	//入力をFF2個で受ける
	reg ff1, ff2;
	
	always @(posedge clk) begin
		if(~rst) begin
			ff1 <= 1'b0;
			ff2 <= 1'b0;
		end
		else if(en40hz) begin
			ff2 <= ff1;
			ff1 <= bin;
		end
	end
	
	wire temp = ~ff1 & ff2 & en40hz;
	
	always @(posedge clk) begin
		if(~rst)
			bout <= 1'b0;
		else
			bout <= temp;
	end
	*/
	
endmodule
