`include "def.h"
module dmem (
 input clk,
 input [15:0] a,
 output [`DATA_W-1:0] rd,
 input [`DATA_W-1:0] wd,
 input  we);

	reg [`DATA_W-1:0] mem[0:`DEPTH-1];

	assign rd = mem[a];

	always @(posedge clk)  begin
		if(we) mem[a] <= wd;
	end
	initial
      begin
           $readmemh("dmem.dat", mem);
    end


endmodule
