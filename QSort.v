module partition(xin,xout,i,j,loc_in,loc_out,clk,init,complete,read,write);
parameter N = 8;
input clk,init,read,write;
reg[31:0] vec[0:N-1];
input[31:0] xin;
input[31:0] i,j;
input[31:0] loc_in;
output reg[31:0] loc_out,xout;
output reg complete;
reg[31:0] right,left,loc;
reg set;
reg[31:0] temp,count;
reg[3:0] state;
parameter S0=4'b0000,S1=4'b0001,S2=4'b0010,S3=4'b0011,S4=4'b0100,S5=4'b0101,S6=4'b0110,S7=4'b0111,S8=4'b1000;
// always @(posedge init) begin
//     state<=S0;
//     set<=0;
//     loc<=loc_in;
//     complete<=0;
//     left<=i;
//     right<=j;
// end
always @(posedge clk) begin
  if(read && count!=N)begin
  vec[count]<=xin;
  count<=count+1;
  end
  else if(~read && ~write)count<=0;
end
always @(posedge clk) begin
  if(write && count!=N)begin
    xout<=vec[count];
    count=count+1;
  end
end
always @(posedge clk) begin
    case(state)
    S0:begin state<=init?S1:S0; complete<=0;loc<=loc_in;complete<=0;left<=i;right<=j;end
    S1:begin
      complete<=0;
      if(vec[loc]<=vec[right] && loc!=right)state<=S2;
      else if(vec[loc]>vec[right])begin state<=S4;vec[loc]<=vec[right];vec[right]<=vec[loc];loc<=right;end
      else if(loc==right)state<=S3;
    end
    S2:begin
      if(vec[loc]<=vec[right] && loc!=right)begin state<=S2;right<=right-1;end
      else if(vec[loc]>vec[right])begin state<=S4;vec[loc]<=vec[right];vec[right]<=vec[loc];loc<=right;end
      else if(loc==right)state<=S3;
    end
    S3:begin state<=S0;set<=1;complete<=1;loc_out<=loc;end
    S4:begin
      if(vec[loc]>=vec[left] && left!=loc)state<=S5;
      else if(vec[loc]<vec[left])begin state<=S7;vec[loc]<=vec[left];vec[left]<=vec[loc];loc<=left; end
      else if(loc==left)state<=S6;
    end
    S5:begin
      if(vec[loc]>=vec[left] && left!=loc)begin state<=S5;left<=left+1; end
      else if(vec[loc]<vec[left])begin state<=S7;vec[loc]<=vec[left];vec[left]<=vec[loc];loc<=left; end
      else if(loc==left)state<=S6;
    end
    S6:begin state<=init?S0:S6;set<=1;complete<=1;loc_out<=loc;end
    S7:state<=S1;
    endcase
end
endmodule
module stack(clk,val1,val2,push,pop,ret1,ret2,empty);
parameter N = 64;
input[31:0] val1,val2;
input clk,push,pop;
output reg empty;
output reg[31:0] ret1,ret2;
reg[31:0]  counter;
reg[31:0] mem[0:N];
always @(posedge clk) begin
    if(push)begin
        mem[counter]<=val2;
        mem[counter+1]<=val1;
        counter<=counter+2;
    end
    else if(pop && counter!=0)begin
      ret1<=mem[counter-1];
      ret2<=mem[counter-2];
      counter<=counter-2;
    end
end
always @(counter) begin
    empty<=(counter==0);
end
endmodule
module controller(clk,init,size,empty,complete,ret1,ret2,val1,val2,loc,push,pop,init_p,Qcomp);
input clk,init,empty,complete;
input[31:0] ret1,ret2,loc,size;
output reg push,pop,init_p;
output reg[31:0] val1,val2;
output reg Qcomp;
parameter S0=4'b0000,S1=4'b0001,S2=4'b0010,S3=4'b0011,S4=4'b0100,S5=4'b0101,S6=4'b0110,S7=4'b0111,S8=4'b1000,S9=4'b1001,Si=4'b1010;
reg[3:0] state;
reg[31:0]  i,j;
//reg[31:0] loc;
always @(posedge clk) begin
    case(state)
    S0:state<=init?S9:Si;
    Si:state<=init?S0:Si;
    S9:state<=S1;
    S1:state<=empty?S0:S2;
    S2:state<=S3;
    S3:state<=S4;
    S4:state<=complete?S5:S4;
    S5:state<=S6;
    S6:state<=S7;
    S7:state<=S8;
    S8:state<=S1;
    endcase
end
always @(state) begin
    case(state)
    S0:begin push<=1;val1<=0;val2<=size-1;Qcomp<=0;init_p<=0;end
    Si:begin Qcomp<=1;push<=0;end
    S9:begin push<=0;end
    S2:begin pop<=1;push<=0;end
    S3:pop<=0;
    S4:init_p<=1;
    S5:init_p<=0;
    S6:begin if(ret1<(loc-1) && loc>0)begin 
    push<=1;val1<=ret1;val2<=loc-1;end end
    S7:begin if((loc+1)<ret2 && loc[31]==0)begin
      push<=1;val1<=loc+1;val2<=ret2;
    end
    end
    S8:push<=0;
    endcase
end
endmodule
module  QSort(xin,xout,init,clk,Qcomp,read,write);
parameter N=8 ;
input clk,init,read,write;
output Qcomp;
input[31:0] xin;
output[31:0] xout;
wire[31:0] ret1,ret2,val1,val2,out;
wire[31:0] size;
wire init_p,empty,complete,push,pop,c;
assign size=N;
assign c=clk;
controller C(clk,init,size,empty,complete,ret1,ret2,val1,val2,out,push,pop,init_p,Qcomp);
stack S(clk,val1,val2,push,pop,ret1,ret2,empty);
partition P(xin,xout,ret1,ret2,ret1,out,clk,init_p,complete,read,write);
endmodule