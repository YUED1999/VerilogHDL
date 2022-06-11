module FFT1024(
	input clk,
	input rst,
	input write_enable,
	input signed [15:0] in_re,
	input signed [15:0] in_im,
	output reg signed [15:0] out_re,
	output reg signed [15:0] out_im,
	output reg done
);

	parameter N = 1024; //変更
	
	reg write_fin;
	reg fft_fin;
	
	wire signed [16:0] Wn_re;
	wire signed [16:0] Wn_im;
	
	reg bf_enable0;
	reg bf_enable1;
	reg bf_enable2;
	reg signed [31:0] tmp_rekd, tmp_imkd, tmp_rek, tmp_imk;
	reg [10:0] tmp_kd, tmp_k;
	reg signed [31:0] tmp_rekd2, tmp_imkd2, tmp_rek2, tmp_imk2;
	reg [10:0] tmp_kd2, tmp_k2;
	
	reg [10:0] i;
	//正順 i[10] i[9] i[8] i[7] i[6] i[5] i[4] i[3] i[2] i[1] i[0]
	//逆順 i[0] i[1] i[2] i[3] i[4] i[5] i[6] i[7] i[8] i[9] i[10]
	//上記は誤り
	//32点の場合は
	//正順 i[4] i[3] i[2] i[1] i[0]
	//逆順 i[0] i[1] i[2] i[3] i[4]
	//となる
	//ビット逆順のiは{i[0], i[1], i[2], i[3], i[4]}で表現できる
	reg [10:0] l;
	reg [10:0] j;
	reg [10:0] k;
	reg [10:0] r;
	reg [10:0] diff;
	
	reg [10:0] jr;
	
	reg wren_a,wren_b;
	reg wren_a2;
	
	reg [8:0] add_a,add_b;
	reg signed [31:0] wr_re_a,wr_im_a,wr_re_b,wr_im_b;
	
	wire signed [31:0] re_a,re_b, im_a,im_b;
	
	reg [2:0] cnt;
	
	reg out_fin;
	
	ROMREAL rr(.clock(clk), .address(j*r), .q(Wn_re));
	ROMIMAG ri(.clock(clk), .address(j*r), .q(Wn_im));
	
	RAM rre(.data_a(wr_re_a), .address_a(k), .wren_a(wren_a),
			  .data_b(wr_re_b), .address_b(k+diff), .wren_b(wren_b),
			  .clock(clk), .q_a(re_a), .q_b(re_b));

	RAM rim(.data_a(wr_im_a), .address_a(k), .wren_a(wren_a2),
			  .data_b(wr_im_b), .address_b(k+diff), .wren_b(wren_b),
			  .clock(clk), .q_a(im_a), .q_b(im_b));
			  
			  
	//チャタリング除去
	wire write_enable1;
	BTN_IN btn_in0(.clk(clk), .rst(rst), .bin(write_enable), .bout(write_enable1));
	
	always @(posedge clk or negedge rst) begin
		if(!rst) begin
			r <= (N >> 1);
			diff <= 1'b1;
			l <= 0;
			j <= 0;
			k <= 0;
			fft_fin <= 0;
			write_fin <= 0;
			i <= 0;
			
			bf_enable0 <= 1'b0;
			bf_enable1 <= 1'b0;
			bf_enable2 <= 1'b0;
			
			wren_a <= 1'b0;
			wren_b <= 1'b0;
			
			cnt <= 1'b0;
			
			done <= 1'b0;
			out_fin <= 1'b0;
			
		
		end
		else if(write_enable1 == 1'b1) begin
			if(i == 11'd1024) begin //変更
				wren_a <= 1'b0;
				wren_a2 <= 1'b0;
				
				write_fin <= 1'b1;
				k <= 1'b0;
			end
			else begin
				//wren_a <= 1'b1;
				wren_a2 <= 1'b1;
				
				//add_a <= {i[0], i[1], i[2], i[3], i[4], i[5]};
				k <= {i[0], i[1], i[2], i[3], i[4], i[5], i[6], i[7], i[8], i[9]}; //変更
				//wr_re_a <= in_re;
				//wr_im_a <= in_im;
				
				wr_im_a <= 32'd0;
				
				//$display("k=%d ireverse=%d",k,{i[0],i[1],i[2],i[3],i[4],i[5]});
				$display("re_a=%d im_a=%d",re_a,im_a);
				
				i <= i + 1'b1;
			end
		end
		else if(write_fin == 1'b1) begin
			
			if(cnt==3'd2) begin
				cnt <= 3'd0;
				wren_a <= 1'b0;
				
				wren_a2 <= 1'b0;
				
				wren_b <= 1'b0;
				
				if(l<4'd10) begin //変更
					if(k+1'b1 >= N) begin
					
						k <= 0;
						j <= 0;
						l <= l + 1'b1;
						r <= (r >> 1);
						diff <= (diff << 1);
						
						wren_a <= 1'b0;
						
						wren_a2 <= 1'b0;
						
						wren_b <= 1'b0;
							
					end
					else begin
					
						if(j+1'b1 == diff) begin
						
							j <= 0;
							k <= k+diff + 1'b1;
							
						end
						else begin
						
							j <= j + 1'b1;
							k <= k + 1'b1;
							
						end
						
					end
				end
				else begin
					//FFT終了
					bf_enable0 <= 1'b0;
					fft_fin <= 1'b1;
					k <= 1'b0;
				end
			end
			else if(cnt==3'd1) begin
				cnt <= 3'd2;
		
			end
			else if(cnt==3'd0) begin
				cnt <= 3'd1;
				if(l<4'd10) begin //変更
					if(k+1'b1>=N) begin
						bf_enable0 <= 1'b0;
					end
					else begin
						bf_enable0 <= 1'b1;
					end
				end
			end
			
			//bf_enable1 <= bf_enable0;
			//bf_enable2 <= bf_enable1;
			if(bf_enable0 == 1'b1) begin
				wr_re_b <= ($signed(re_a) - (($signed(Wn_re)*$signed(re_b) - $signed(Wn_im)*$signed(im_b)) >>> 15)) >>> 1;
				wr_im_b <= ($signed(im_a) - (($signed(Wn_im)*$signed(re_b) + $signed(Wn_re)*$signed(im_b)) >>> 15)) >>> 1;
				wr_re_a <= ($signed(re_a) + (($signed(Wn_re)*$signed(re_b) - $signed(Wn_im)*$signed(im_b)) >>> 15)) >>> 1;
				wr_im_a <= ($signed(im_a) + (($signed(Wn_im)*$signed(re_b) + $signed(Wn_re)*$signed(im_b)) >>> 15)) >>> 1;
				bf_enable0 <= 1'b0;
				bf_enable1 <= 1'b0;
				bf_enable2 <= 1'b0;
				wren_a <= 1'b1;
				
				wren_a2 <= 1'b1;
				
				wren_b <= 1'b1;
				//$display("butterfly!");
				//$display("bf_enable0=%d",bf_enable0);

		
			end
			
			if(fft_fin == 1'b1) begin
				if(out_fin==1'b0) begin
					if(k<11'd1025) begin //変更
						k <= k + 1'b1;
						if(k<2'd1)begin
						end
						else begin
							done <= 1'b1;
							out_re <= (re_a >>> 5);
							out_im <= (im_a >>> 5);	
						end
					end //if(k<11'd1025)
					else begin
						done <= 1'b0;
						out_re <= 16'd0;
						out_im <= 16'd0;
						out_fin <= 1'b1;
					end //else
				end  //if(out_fin==1'b0)
				else begin
				// out_fin==1'b1
				
				end
				
			end
			
		end
	end

			
endmodule
			