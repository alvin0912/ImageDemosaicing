`timescale 1ns/10ps
module  ATCONV(
	input		clk,
	input		reset,
	output	reg	busy,	
	input		ready,	
			
	output reg	[11:0]	iaddr,
	input signed [12:0]	idata,
	
	output	reg 	cwr,
	output  reg	[11:0]	caddr_wr,
	output reg 	[12:0] 	cdata_wr,
	
	output	reg 	crd,
	output reg	[11:0] 	caddr_rd,
	input 	[12:0] 	cdata_rd,
	
	output reg 	csel
	);

//=================================================
//            write your design below
//=================================================

integer idxZero=3'b000;
parameter A=4'd0,B=4'd1,C=4'd2,D=4'd3,E=4'd4,F=4'd5,G=4'd6,H=4'd7,I=4'd8,J=4'd9;
reg [3:0] state,next_state;

reg [11:0] i,j;

reg [12:0] select[8:0];
reg [3:0] ptrSelect;

reg [11:0] nextAddr[8:0];
reg [4:0] ptrNextAddr;

reg [12:0] tmpResult;
reg [12:0] ptrLayer0;

always@(posedge clk,posedge reset)
	if(reset) state <= J;
	else state <= next_state;

always@(*)
	case(state)
		J:next_state = A;
		A:next_state = B;
		B:begin
			if(ptrSelect == 4'd8)next_state = C;
			else next_state = B;
		end
		C:next_state = D;
		D:begin
			if(ptrLayer0 == 13'd4095) next_state = E;
			else next_state = A;
		end
		E:next_state = F;
		F:begin
			if(ptrSelect == 4'd3)next_state = G;
			else next_state = F;
		end
		G:next_state = H;
		H:begin
			if(ptrLayer0 == 13'd1023) next_state = I;
			else next_state = E;
		end
		default:next_state = J;
	endcase

always @(posedge clk,posedge reset)
	if(reset)begin
		busy <= 1'b0;
		iaddr <= 12'd0;

		cwr <= 1'b0;
		caddr_wr <= 12'd0;
		cdata_wr <= 13'd0;

		crd <= 1'b0;
		caddr_rd <= 12'd0;

		csel <= 1'b0;

		i <= 12'd0;
		j <= 12'd0;

		ptrSelect <= 4'd0;
		for(idxZero=0;idxZero<9;idxZero=idxZero+1)select[idxZero] <= 13'd0;

		ptrNextAddr <= 5'd0;
		for(idxZero=0;idxZero<9;idxZero=idxZero+1)nextAddr[idxZero] <= 12'd0;

		tmpResult <= 13'd0;
		ptrLayer0 <= 13'd0;
	end
	else
		case (state)
			J:begin
				cwr <= 1'b0;
			end
            A:begin
				busy <= 1'b1;
				iaddr <= nextAddr[ptrNextAddr];
				ptrNextAddr <= ptrNextAddr + 1'b1;
				nextAddr[0] <= nextAddr[0]+1'b1;
				//左上角
				if(i<12'd2 & j<12'd2)begin
					nextAddr[1] <= 12'd0;
					nextAddr[2] <= j;
					nextAddr[3] <= j+12'd2;
					nextAddr[4] <= i*12'd64;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= 12'd64*i+12'd128;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= nextAddr[0]+12'd130;
				end
				//右上角
				else if(i<12'd2 & j>12'd61)begin
					nextAddr[1] <= j-12'd2;
					nextAddr[2] <= j;
					nextAddr[3] <= 12'd63;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= i*12'd64+12'd63;
					nextAddr[6] <= nextAddr[0]+12'd126;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= 12'd64*i+12'd191;
				end
				//左下角
				else if(i>12'd61 & j<12'd2)begin
					nextAddr[1] <= 12'd64*i-12'd128;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= nextAddr[0]-12'd126;
					nextAddr[4] <= 12'd64*i;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= 12'd4032;
					nextAddr[7] <= 12'd4032+j;
					nextAddr[8] <= 12'd4034+j;
				end
				//右下角
				else if(i>12'd61 & j>12'd61)begin
					nextAddr[1] <= nextAddr[0]-12'd130;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= 12'd64*i-12'd65;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= 12'd64*i+12'd63;
					nextAddr[6] <= 12'd4030+j;
					nextAddr[7] <= 12'd4032+j;
					nextAddr[8] <= 12'd4095;
				end
				//中上段
				else if(i<12'd2)begin
					nextAddr[1] <= j-12'd2;
					nextAddr[2] <= j;
					nextAddr[3] <= j+12'd2;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= nextAddr[0]+12'd126;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= nextAddr[0]+12'd130;
				end
				//中下段
				else if(i>12'd61)begin
					nextAddr[1] <= nextAddr[0]-12'd130;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= nextAddr[0]-12'd126;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= 12'd4030+j;
					nextAddr[7] <= 12'd4032+j;
					nextAddr[8] <= 12'd4034+j;
				end
				//中右段
				else if(j>12'd61)begin
					nextAddr[1] <= nextAddr[0]-12'd130;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= 12'd64*i-12'd65;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= 12'd64*i+12'd63;
					nextAddr[6] <= nextAddr[0]+12'd126;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= 12'd64*i+12'd191;
				end
				//中左段
				else if(j<12'd2)begin
					nextAddr[1] <= 12'd64*i-12'd128;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= nextAddr[0]-12'd126;
					nextAddr[4] <= 12'd64*i;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= 12'd64*i+12'd128;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= nextAddr[0]+12'd130;
				end
				//中心區
				else begin
					nextAddr[1] <= nextAddr[0]-12'd130;
					nextAddr[2] <= nextAddr[0]-12'd128;
					nextAddr[3] <= nextAddr[0]-12'd126;
					nextAddr[4] <= nextAddr[0]-12'd2;
					nextAddr[5] <= nextAddr[0]+12'd2;
					nextAddr[6] <= nextAddr[0]+12'd126;
					nextAddr[7] <= nextAddr[0]+12'd128;
					nextAddr[8] <= nextAddr[0]+12'd130;
				end

				if(j==12'd63)begin
					if(i==12'd63)begin
						i <= 12'd0;
						j <= 12'd0;
					end
					else begin
						i <= i + 1'b1;
						j <= 12'd0;
					end 
				end
				else j <= j + 1'b1;
			end
			B:begin
				iaddr <= nextAddr[ptrNextAddr];
				select[ptrSelect] <= idata;
				ptrSelect <= ptrSelect + 1'b1;
				if(ptrNextAddr == 4'd8)ptrNextAddr <= 13'd0;
				else ptrNextAddr <= ptrNextAddr + 1'b1;
			end
			C:begin
				tmpResult <= (select[0]
								-{4'b0000,select[1][12:8],4'b0000}
								-{3'b000 ,select[2][12:7],4'b0000}
								-{4'b0000,select[3][12:8],4'b0000}
								-{2'b00  ,select[4][12:6],4'b0000}
								-{2'b00  ,select[5][12:6],4'b0000}
								-{4'b0000,select[6][12:8],4'b0000}
								-{3'b000 ,select[7][12:7],4'b0000}
								-{4'b0000,select[8][12:8],4'b0000})
								-
								({9'd0,select[1][7:4]}
								+{9'd0,select[2][6:4],1'd0}
								+{9'd0,select[3][7:4]}
								+{9'd0,select[4][5:4],2'd0}
								+{9'd0,select[5][5:4],2'd0}
								+{9'd0,select[6][7:4]}
								+{9'd0,select[7][6:4],1'd0}
								+{9'd0,select[8][7:4]})
								-13'd12;
			end
			D:begin
				cwr <= 1'b1;
				caddr_wr <= ptrLayer0;
				ptrLayer0 <= ptrLayer0 + 1'b1;
				ptrNextAddr <= 13'd0;
				ptrSelect <= 13'd0;
				if(tmpResult[12] == 1'd1) cdata_wr <= 13'd0;
				else cdata_wr <= tmpResult;

				if(next_state == E)begin
					i <= 13'd0;
					j <= 13'd1;
					ptrLayer0 <= 13'd0;
				end
				else begin
					i <= i;
					j <= j;
				end
			end
			E:begin
				csel <= 1'b0;
				cwr <= 1'b0;
				crd <= 1'b1;
				caddr_rd <= nextAddr[ptrNextAddr];
				ptrNextAddr <= ptrNextAddr + 1'd1;
				nextAddr[0] <= i*13'd128+j*13'd2;
				nextAddr[1] <= nextAddr[0] + 1'd1;
				nextAddr[2] <= nextAddr[0] + 13'd64;
				nextAddr[3] <= nextAddr[0] + 13'd65;

				if(j==12'd31)begin
					if(i==12'd31)begin
						i <= 12'd0;
						j <= 12'd0;
					end
					else begin
						i <= i + 1'b1;
						j <= 12'd0;
					end 
				end
				else j <= j + 1'd1;
			end
			F:begin
				caddr_rd <= nextAddr[ptrNextAddr];
				select[ptrSelect] <= cdata_rd;
				ptrSelect <= ptrSelect + 1'b1;
				if(ptrNextAddr == 4'd3)ptrNextAddr <= 13'd0;
				else ptrNextAddr <= ptrNextAddr + 1'b1;
			end
			G:begin
				csel <= 1'b1;
				crd <= 1'b0;
				if(select[0] >= select[1])select[0] <= select[0];
				else select[0] <= select[1];

				if(select[2] >= select[3])select[2] <= select[2];
				else select[2] <= select[3];
			end
			H:begin
				cwr <= 1'b1;
				caddr_wr <= ptrLayer0;
				ptrLayer0 <= ptrLayer0 + 1'b1;
				ptrNextAddr <= 13'd0;
				ptrSelect <= 13'd0;
				if(select[0] >= select[2])begin
					if(select[0][3:0] == 4'b0)cdata_wr <= select[0];
					else cdata_wr <= {select[0][12:4] + 1'b1 , 4'b0};
				end
				else begin
					if(select[2][3:0] == 4'b0)cdata_wr <= select[2];
					else cdata_wr <= {select[2][12:4] + 1'b1 , 4'b0};
				end
			end
            default:begin
				busy <= 1'b0;
			end
        endcase

endmodule