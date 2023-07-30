/* test bench */
`timescale 1ns/1ps
`include "def.h"
module test_rv32i;
parameter STEP = 10;
   reg clk, rst_n;
   wire [`DATA_W-1:0] ddataout, ddatain ;
   wire [`DATA_W-1:0] iaddr;
   wire [`DATA_W-1:0] daddr;
   wire [`DATA_W-1:0] idata;
   wire we, ecall_op;
   reg [31:0] count, sc_lw, sc_bb, sc_ab;
   integer FP;
   integer i;
  
   always #(STEP/2) begin
            clk <= ~clk;
   end

   rv32i rv32i_1(.clk(clk), .rst_n(rst_n), .instr(idata),
               .readdata(ddatain), .pc(iaddr), .adrdata(daddr),
               .writedata(ddataout), .we(we), .ecall(ecall_op) );
  imem  imem_1(.a(iaddr[17:2]), .rd(idata) );
  dmem  dmem_1(.clk(clk), .a(daddr[17:2]), .rd(ddatain), 
  					.wd(ddataout), .we(we) );

   initial begin
      $dumpfile("rv32i.vcd");
      $dumpvars(0,test_rv32i);
      FP= $fopen("result.dat");
      clk <= `DISABLE;
      rst_n <= `ENABLE_N;
	  count <= 0;
	  sc_lw <= 0;
	  sc_bb <= 0;
	  sc_ab <= 0;
   #(STEP*1/4)
   #STEP
      rst_n <= `DISABLE_N;
   #(STEP*10000)
   $finish;
   end

   always @(negedge clk) begin
      $display("pc:%h/%d idatain:%h", rv32i_1.pc, rv32i_1.pc, rv32i_1.instr);
      $display("x1:%h x2:%h x3:%h x4:%h x5:%h x6:%h x7:%h", 
	rv32i_1.rfile_1.rf[1], rv32i_1.rfile_1.rf[2],
	rv32i_1.rfile_1.rf[3], rv32i_1.rfile_1.rf[4], rv32i_1.rfile_1.rf[5],
	rv32i_1.rfile_1.rf[6], rv32i_1.rfile_1.rf[7] );
`ifdef REGALL
      $display("x8:%h x9:%h x10:%h x11:%h x12:%h x13:%h x14:%h x15:%h", 
	rv32i_1.rfile_1.rf[8], rv32i_1.rfile_1.rf[9],
	rv32i_1.rfile_1.rf[10], rv32i_1.rfile_1.rf[11], rv32i_1.rfile_1.rf[12],
	rv32i_1.rfile_1.rf[13], rv32i_1.rfile_1.rf[14], rv32i_1.rfile_1.rf[15] );
      $display("x16:%h x17:%h x18:%h x19:%h x20:%h x21:%h x22:%h x23:%h", 
	rv32i_1.rfile_1.rf[16], rv32i_1.rfile_1.rf[17],
	rv32i_1.rfile_1.rf[18], rv32i_1.rfile_1.rf[19], rv32i_1.rfile_1.rf[20],
	rv32i_1.rfile_1.rf[21], rv32i_1.rfile_1.rf[22], rv32i_1.rfile_1.rf[23] );
      $display("x24:%h x25:%h x26:%h x27:%h x28:%h x29:%h x30:%h x31:%h", 
	rv32i_1.rfile_1.rf[24], rv32i_1.rfile_1.rf[25],
	rv32i_1.rfile_1.rf[26], rv32i_1.rfile_1.rf[27], rv32i_1.rfile_1.rf[28],
	rv32i_1.rfile_1.rf[29], rv32i_1.rfile_1.rf[30], rv32i_1.rfile_1.rf[31] );
`endif

    $display("dmem:%h %h %h %h", dmem_1.mem[0], dmem_1.mem[1], dmem_1.mem[2], dmem_1.mem[3] );
    $display("");
	count <= count+1;
	if(rv32i_1.lwstall) sc_lw <= sc_lw+1;
	if(rv32i_1.branchstall) sc_bb <= sc_bb+1;
	if(!rv32i_1.stall & rv32i_1.bra_op) sc_ab <= sc_ab+1;
	if(ecall_op) begin 
	   for(i=0; i<200; i=i+1)
              $fdisplay(FP,"%h", dmem_1.mem[i]);
	   $display("ecall detected: count =%d ",count); 
	   $display("stall/lw =%d",sc_lw); 
	   $display("stall/before branch =%d",sc_bb); 
	   $display("stall/after branch =%d",sc_ab); 
	$finish; end

   end 
endmodule
