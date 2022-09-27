module Qtest;
parameter N=8 ;
reg clk,init,read,write;
reg[31:0] xin;
wire[31:0] xout;
wire Qcomp;
integer i,c;
integer seed=10;
QSort DUT(xin,xout,init,clk,Qcomp,read,write);
initial begin
    clk=0;
    init=0;
    read=0;
    write=0;
    DUT.P.state=4'b0000;
    DUT.C.state=4'b0000;
    DUT.P.set=0;
   // DUT.P.vec[0]=13;DUT.P.vec[1]=2;DUT.P.vec[2]=8;DUT.P.vec[3]=12;DUT.P.vec[4]=1;DUT.P.vec[5]=3;DUT.P.vec[6]=31;DUT.P.vec[7]=22;
    DUT.S.counter=0;
    for(i=0;i<64;i=i+1)begin
      DUT.S.mem[i]=0;
    end
    #10 read=1;
    xin=$urandom(seed)%100;
    for(i=0;i<7;i=i+1)begin
      #10 xin=$urandom(seed)%100;
    end
    //xin=6;#10 xin=2;#10 xin=8;#10 xin=12;#10 xin=1;#10 xin=3;#10 xin=31;#10 xin=22;
    #10 read=0;
    for(c=0;c<N;c=c+1)begin
      $write("%0d ",DUT.P.vec[c]);
    end
    $write("\n");
    #10 init=1;
    #20 init=0;
    #1000 write=1;
    #5000 $finish;
end
always #5 clk=~clk;
initial begin
    $dumpfile("Qtest.vcd");
    $dumpvars(0,Qtest);
end
always @(posedge Qcomp) begin
    for(c=0;c<N;c=c+1)begin
      $write("%0d ",DUT.P.vec[c]);
    end
    $write("\n");
end
endmodule